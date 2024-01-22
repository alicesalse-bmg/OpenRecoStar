from qgis.PyQt.QtGui import *
from qgis.PyQt.QtWidgets import *
from qgis.PyQt.QtSql import *
from qgis.PyQt.QtCore import *
from qgis.utils import Qgis
from qgis.core import QgsProject, QgsDataSourceUri, QgsWkbTypes, QgsMapLayerType, QgsFeature, QgsLayerTreeGroup, QgsLayerTreeLayer, QgsFieldConstraints, QgsEditorWidgetSetup, QgsDefaultValue, QgsVectorLayer, QgsPoint, QgsGeometry, QgsCoordinateTransform, QgsCoordinateReferenceSystem
# initialize Qt resources from file resources.py
# execute : pyrcc5 -o resources.py resources.qrc
from . import resources
from qgis import processing
import uuid
import os

class MappingDialogBox(QDialog):
    def __init__(self, title, formlayout, parent=None):
        super(MappingDialogBox, self).__init__(parent=None)

        self.parent = parent
        self.formlayout = formlayout
        self.layout = QGridLayout()

        l = 0
        for label in self.formlayout :
            type, valuelist, other = self.formlayout[label]
            if type == 'ComboBox' :
                newrow = QComboBox()
                newrow.addItems(valuelist)
                newrow.currentTextChanged.connect(self.set_visible)
                self.layout.addWidget(QLabel(label), l, 0)
                self.layout.addWidget(newrow, l, 1)

            elif type == 'LineEdit' :
                self.layout.addWidget(QLabel(label), QLineEdit())
            l+=1

        QBtn = QDialogButtonBox.Ok | QDialogButtonBox.Cancel
        buttonBox = QDialogButtonBox(QBtn, self)
        buttonBox.accepted.connect(self.accept_test)
        buttonBox.rejected.connect(self.reject)
        self.layout.addWidget(buttonBox,self.layout.rowCount(),1,-1,-1)

        self.setLayout(self.layout)
        self.setModal(True)
        self.setWindowTitle(title)

    def set_visible(self):
        i = 0
        while i < self.layout.rowCount() :
            wlabel=self.layout.itemAtPosition(i,0) #Label
            wfield=self.layout.itemAtPosition(i,1) #Field
            if isinstance(wlabel, QLayoutItem):
                wlabel=wlabel.widget()
                if isinstance(wlabel, QLabel):
                    if isinstance(wfield, QLayoutItem):
                        wfield=wfield.widget()
                        # print(i, wlabel.text())
                        if isinstance(wfield, QComboBox):
                            if wfield.currentText() == '<AUTRE>' and not self.layout.itemAtPosition(i,2) :
                                # print('add widget',wlabel.text())
                                if isinstance(self.formlayout[wlabel.text()][2], list) :
                                    newcol = QComboBox()
                                    newcol.addItems(self.formlayout[wlabel.text()][2])
                                    self.layout.addWidget(newcol, i, 2)
                                else:
                                    self.layout.addWidget(QLineEdit(self.formlayout[wlabel.text()][2]), i, 2)
                                    # TODO : mettre des contraintes selon le type d'attribut
                                self.layout.setColumnMinimumWidth(2, 300)
                            elif wfield.currentText() != '<AUTRE>' and self.layout.itemAtPosition(i,2) :
                                # print('remove widget',wlabel.text())
                                wfield2=self.layout.itemAtPosition(i,2)
                                self.layout.removeWidget(wfield2.widget())
            i+=1

    def accept_test(self):
        accept=True
        for i in range(0,self.layout.rowCount()-1):
            wfield=self.return_text(self.layout.itemAtPosition(i,1))
            if wfield == '<AUTRE>' and self.layout.itemAtPosition(i,2) :
                wfield2=self.return_text(self.layout.itemAtPosition(i,2))
                if not wfield2 :
                    wlabel=self.return_text(self.layout.itemAtPosition(i,0))
                    self.parent.iface.messageBar().pushMessage("Formulaire incomplet", "L'attribut  `{0}`  n'est pas défini".format(wlabel), Qgis.Warning, duration=3)
                    accept=False
                    break
            else :
                pass
        if accept :
            self.accept()

    def get_output(self):
        map_dict = {}
        for i in range(0,self.layout.rowCount()-1):
            wlabel=self.return_text(self.layout.itemAtPosition(i,0)) #Label
            wfield=self.return_text(self.layout.itemAtPosition(i,1)) #Field1
            if wfield == '<AUTRE>' and self.layout.itemAtPosition(i,2) :
                wfield2=self.return_text(self.layout.itemAtPosition(i,2).widget())
                map_dict[wlabel]="'%s'" % wfield2
            else :
                map_dict[wlabel]=wfield
        return map_dict

    def return_text(self, witem) :
        if isinstance(witem, QLayoutItem):
            wtext = self.return_text(witem.widget())
        elif isinstance(witem, QLabel):
            wtext=witem.text()
        elif isinstance(witem, QLineEdit):
            wtext=witem.text()
        elif isinstance(witem, QComboBox):
            wtext=witem.currentText()

        return wtext



class LinefromPLORDialog(QDialog):
    def __init__(self, plor_lyrnames, line_lyrnames, parent=None):
        super(LinefromPLORDialog, self).__init__(parent=None)

        self.parent = parent

        self.layout = QFormLayout()
        self.layout.setLabelAlignment(Qt.AlignRight)

        self.plorlyr = QComboBox()
        self.plorlyr.addItems(plor_lyrnames)
        self.layout.addRow("Couche d'origine",self.plorlyr)

        self.ordertyp = QComboBox()
        self.ordertyp.addItems(['Ordonner par proximité', 'Ordonner par "Numero"'])
        self.layout.addRow("Type de tracé",self.ordertyp)

        self.linelyr = QComboBox()
        self.linelyr.addItems(line_lyrnames)
        self.layout.addRow("Couche de destination",self.linelyr)

        QBtn = QDialogButtonBox.Ok | QDialogButtonBox.Cancel
        self.buttonBox = QDialogButtonBox(QBtn, self)
        self.buttonBox.accepted.connect(self.accept_test)
        self.buttonBox.rejected.connect(self.reject)
        self.layout.addRow(self.buttonBox)

        self.setLayout(self.layout)
        self.setModal(True)
        self.setWindowTitle("Création d'un ouvrage linéaire a partir de points levés")

    def accept_test(self):
        if (self.plorlyr.currentText() and self.linelyr.currentText() and self.ordertyp.currentText() ) :
            print("ok")
            self.accept()

    def get_output(self):
        return [self.plorlyr.currentText(),self.linelyr.currentText(),self.ordertyp.currentText()]

class RecoStarTools:

    def __init__(self, iface):
        # save reference to the QGIS interface
        self.iface = iface
        self.root = iface.layerTreeView().layerTreeModel().rootGroup()

    def initGui(self):
        self.toolbar = self.iface.addToolBar("RecoStarTools")
        self.toolbar.setObjectName("Outils OpenRecoStar")

        self.importplor = QAction(QIcon(":/qgs_plugins/OpenRecoStarPlugin/icons/ImportPointLeve.png"),
                                    "Importer les Points Levés",
                                    self.iface.mainWindow())
        self.importplor.setObjectName("ImportPLOR")
        self.importplor.setWhatsThis("Importer les Points Levés")
        self.importplor.setStatusTip("Import des PLOR")
        self.importplor.triggered.connect(self.importPLOR)
        self.toolbar.addAction(self.importplor)

        self.linefromplor = QAction(QIcon(":/qgs_plugins/OpenRecoStarPlugin/icons/TracePointLeve.png"),
                                    "Tracer les lignes à partir des Points Levés",
                                    self.iface.mainWindow())
        self.linefromplor.setObjectName("LinefromPLOR")
        self.linefromplor.setWhatsThis("Tracer les lignes à partir des Points Levés")
        self.linefromplor.setStatusTip("Trace les ligne")
        self.linefromplor.triggered.connect(self.linefromPLOR)
        self.toolbar.addAction(self.linefromplor)

        self.gpkg2gml = QAction(QIcon(":/qgs_plugins/OpenRecoStarPlugin/icons/ExportGML.png"),
                                    "Exporter le geopackage en GML",
                                    self.iface.mainWindow())
        self.gpkg2gml.setObjectName("GPKG2GML")
        self.gpkg2gml.setWhatsThis("Exporter le geopackage en GML")
        self.gpkg2gml.setStatusTip("Export GML")
        self.gpkg2gml.triggered.connect(self.GPKG2GML)
        self.toolbar.addAction(self.gpkg2gml)

    def unload(self):
        del self.toolbar

    def getLayerFromTable(self, tablename) :
        for layer in [l.layer() for l in self.root.findLayers() if l.layer().type() == QgsMapLayerType.VectorLayer] :
            if len(list(layer.dataProvider().uri().parameterKeys())) > 0 :
                if tablename == layer.dataProvider().uri().params(list(layer.dataProvider().uri().parameterKeys())[0])[0] :
                    return layer

    def getLayersFromTable(self, tablename) :
        layers = []
        for layer in [l.layer() for l in self.root.findLayers() if l.layer().type() == QgsMapLayerType.VectorLayer] :
            if len(list(layer.dataProvider().uri().parameterKeys())) > 0 :
                if tablename in layer.dataProvider().uri().params(list(layer.dataProvider().uri().parameterKeys())[0])[0] :
                    layers.append(layer)
        return layers

    def selectLayerFromTable(self, tablename, expression) :
        for layer in [l.layer() for l in self.root.findLayers() if l.layer().type() == QgsMapLayerType.VectorLayer] :
            if len(list(layer.dataProvider().uri().parameterKeys())) > 0 :
                if tablename in layer.dataProvider().uri().params(list(layer.dataProvider().uri().parameterKeys())[0])[0] :
                    layer.selectByExpression(expression)

    def messageBox(self, level, titre, message=None, detail=None, button=None):
        msgBox = QMessageBox()
        if level == 'Info' :
            messlevel = Qgis.Info
            msgBox.setIcon(QMessageBox.Info)
        elif level == 'Success' :
            messlevel = Qgis.Info
            msgBox.setIcon(QMessageBox.Info)
        elif level == 'Warning' :
            messlevel = Qgis.Warning
            msgBox.setIcon(QMessageBox.Warning)
        elif level == 'Critical' :
            messlevel = Qgis.Critical
            msgBox.setIcon(QMessageBox.Critical)
        msgBox.setText(titre)
        if message :
            msgBox.setInformativeText(message)
        if detail :
            msgBox.setDetailedText(detail)
        if button :
            msgBox.setStandardButtons(button);
        rep = msgBox.exec()
        self.iface.messageBar().pushMessage(titre, message, detail, messlevel, duration=3)
        print(titre, message, detail, rep)
        return rep

    def importPLOR(self) :
        print("importPLOR: run called!")
        file = QFileDialog.getOpenFileName(QFileDialog(), "Importer le fichier", filter="CSV / SHP (*.csv *.shp)")
        print(file)
        if file[0] :
            vlayer = QgsVectorLayer(file[0], "importPLOR_lyr", "ogr")
            file_type = file[0][-3:].lower()
            if not vlayer.isValid():
                print("Layer failed to load!")
                self.iface.messageBar().pushMessage("Impossible de charger la couche", Qgis.Critical)
                return
            else:
                # Qgsproject=QgsProject.instance()
                # Qgsproject.instance().addMapLayer(vlayer)
                vlyr_attrib =  vlayer.fields().names()
                plor_lyrs = self.getLayersFromTable('PointLeveOuvrageReseau')
                plor_lyrnames = [lyr.name() for lyr in plor_lyrs]
                plor_lyrname, ctrl = QInputDialog.getItem(QInputDialog(), "Couche", "Choisir la couche dans laquelle importer les données", plor_lyrnames, 0)
                if ctrl :
                    plor_lyr = plor_lyrs[plor_lyrnames.index(plor_lyrname)]
                    def copyPLOR() :
                        if not plor_lyr.dataProvider().transaction():
                            self.messageBox('Critical', "Import abandonné", "L'import ne peut aboutir", "Aucune session de mise à jour n'est ouverte")
                            return
                        elif plor_lyr.dataProvider().transaction():
                            self.iface.messageBar().clearWidgets()
                            plor_attrib = plor_lyr.fields().names()
                            formlayout = {}
                            for attrib in [a for a in plor_attrib if a not in ['ogr_pkid', 'pkid', 'id', 'Leve_uom']] :
                                attrib_stp = plor_lyr.editorWidgetSetup(plor_attrib.index(attrib))
                                # print(attrib, attrib_stp.config())
                                if attrib_stp.type() == 'ValueRelation':
                                    value_lyr = self.root.findLayer(attrib_stp.config()['Layer']).layer()
                                    value_list = [f['valeurs'] for f in value_lyr.getFeatures()]
                                    sort_attrib = self.sortsimilarity(attrib, vlyr_attrib)
                                    if sort_attrib[1] > 0.5 :
                                        formlayout[attrib] = ('ComboBox',sort_attrib[0]+['<AUTRE>'],value_list)
                                    else :
                                        formlayout[attrib] = ('ComboBox',['<AUTRE>']+sort_attrib[0],value_list)
                                else :
                                    defvalue_lyr=plor_lyr.fields().field(plor_attrib.index(attrib)).defaultValueDefinition().expression().strip().strip("'").strip()
                                    sort_attrib = self.sortsimilarity(attrib, vlyr_attrib)
                                    if sort_attrib[1] > 0.5 :
                                        formlayout[attrib] = ('ComboBox',sort_attrib[0]+['<AUTRE>'],defvalue_lyr)
                                    else :
                                        formlayout[attrib] = ('ComboBox',['<AUTRE>']+sort_attrib[0],defvalue_lyr)
                                    # TODO ajouter des infos sur le type d'attribut
                            if file_type == 'csv' :
                                formlayout['GeomX'] = ('ComboBox',self.sortsimilarity('X', vlyr_attrib)[0],None)
                                formlayout['GeomY'] = ('ComboBox',self.sortsimilarity('Y', vlyr_attrib)[0],None)
                                formlayout['GeomZ'] = ('ComboBox',self.sortsimilarity('Z', vlyr_attrib)[0],None)
                                formlayout['GeomEPSG'] = ('ComboBox', ['2154','3950','3949','3948','3847','3946','3945','3944','3943','3942','27561','27562','27563','27564','27571','27572','27573','27574','<AUTRE>'],None)
                            dial = MappingDialogBox("Import fichier PLOR", formlayout, self)
                            if dial.exec() == QDialog.Accepted:
                                mapping=dial.get_output()
                                print(mapping)
                                for vfeat in vlayer.getFeatures() :
                                    pfeat=QgsFeature(plor_lyr.fields())
                                    pfeat.setAttribute('id', str(uuid.uuid4()))
                                    # pfeat.setAttribute('Leve_uom', plor_lyr.fields().field(plor_attrib.index('Leve_uom')).defaultValueDefinition().expression().strip().strip("'").strip())
                                    if file_type == 'csv' :
                                        # print(vfeat.attribute(mapping['GeomX']), vfeat.attribute(mapping['GeomY']), vfeat.attribute(mapping['GeomZ']))
                                        geom_point=QgsGeometry(QgsPoint(float(vfeat.attribute(mapping['GeomX'])), float(vfeat.attribute(mapping['GeomY'])), float(vfeat.attribute(mapping['GeomZ']))))
                                        transform = QgsCoordinateTransform()
                                        geom_point.transform(QgsCoordinateTransform(QgsCoordinateReferenceSystem("EPSG:{0}".format(mapping['GeomEPSG'].strip("'"))), QgsCoordinateReferenceSystem("EPSG:2154"), QgsProject.instance()))
                                        pfeat.setGeometry(geom_point)
                                    elif file_type == 'shp' :
                                        geom_shp=vfeat.geometry()
                                        geom_shp.transform(QgsCoordinateTransform(vlayer.dataProvider().sourceCrs(), QgsCoordinateReferenceSystem("EPSG:2154"), QgsProject.instance()))
                                        pfeat.setGeometry(geom_shp)
                                    for m in mapping :
                                        fset=False
                                        if (file_type == 'csv' and m[:4] != 'Geom') or file_type != 'csv' :
                                            print(m, mapping[m])
                                            if m == 'Leve' :
                                                if mapping['Leve'] == "'$z'" :
                                                    print ('getZ', pfeat.geometry().get().z())
                                                    pfeat.setAttribute(m, pfeat.geometry().get().z())
                                                    fset=True
                                                elif not (mapping['Leve'][0] == "'" and mapping['Leve'][-1] == "'") :
                                                    if vfeat.attribute(mapping['Leve']) == '' or not vfeat.attribute(mapping['Leve']) :
                                                        print ('null getZ', pfeat.geometry().get().z())
                                                        pfeat.setAttribute(m, pfeat.geometry().get().z())
                                                        fset=True
                                            elif m == 'TypeLeve' :
                                                if mapping['Leve'] == "'$z'" :
                                                    pfeat.setAttribute(m, "AltitudeGeneratrice")
                                                    fset=True
                                                elif not (mapping['Leve'][0] == "'" and mapping['Leve'][-1] == "'") :
                                                    if vfeat.attribute(mapping['Leve']) == '' or not vfeat.attribute(mapping['Leve']) :
                                                        pfeat.setAttribute(m, "AltitudeGeneratrice")
                                                        fset=True
                                            if mapping[m][0] == "'" and mapping[m][-1] == "'" and not fset:
                                                pfeat.setAttribute(m, mapping[m].strip("'"))
                                            elif not fset :
                                                pfeat.setAttribute(m, vfeat.attribute(mapping[m]))

                                    result=plor_lyr.addFeature(pfeat)
                                self.iface.messageBar().pushMessage("Création réussie", Qgis.Success)
                                return
                    if not plor_lyr.dataProvider().transaction():
                        self.iface.messageBar().pushMessage("Ouvrir la session de mise à jour", Qgis.Warning, duration=5)
                        QTimer.singleShot(5000, copyPLOR)
                    else :
                        copyPLOR()

    def similarity(self, a, b) :
        def match(a, b) :
            score, cnt =  0, 0
            for i in range(0, max(len(a)-2 , 1)):
                if a[i:i+3].lower() in b.lower() :
                    score += 1
                cnt+=1
            return score/cnt
        score1 = match(a, b)
        score2 = match(b, a)
        return (score1+score2)/2

    def sortsimilarity(self, a, l) :
        newlist = []
        for i in l :
            score=self.similarity(a,i)
            newlist.append((i,score))
        newlist.sort(reverse=True, key=lambda index: index[1])
        return [n for n, s in newlist], max([s for n, s in newlist])

    def allPointLayerSelected(self) :
        lyrs = []
        for layer in [l.layer() for l in self.root.findLayers() if l.layer().type() == QgsMapLayerType.VectorLayer and l.layer().geometryType() == QgsWkbTypes.PointGeometry] : ## 0 = VectorLayer
            if layer.selectedFeatureIds():
                lyrs.append(layer)
        return lyrs

    def allLineLayers(self) :
        layers = []
        for layer in [l.layer() for l in self.root.findLayers() if l.layer().type() == QgsMapLayerType.VectorLayer and l.layer().geometryType() == QgsWkbTypes.LineGeometry] :
            layers.append(layer)
        return layers

    def linefromPLOR(self) :
        print("linefromPLOR: run called!")
        plor_lyrs = self.allPointLayerSelected()
        plor_lyr = None
        if plor_lyrs :
            plor_lyrnames = [lyr.name() for lyr in plor_lyrs]
        else :
            plor_lyrs = self.getLayersFromTable('PointLeveOuvrageReseau')
            plor_lyrnames = [lyr.name() for lyr in plor_lyrs]
        line_lyrs=self.allLineLayers()
        line_lyrnames = [lyr.name() for lyr in line_lyrs]
        dial = LinefromPLORDialog(plor_lyrnames, line_lyrnames, self)
        if dial.exec() == QDialog.Accepted:
            plor_lyrname,line_lyrname,order_type=dial.get_output()
            plor_lyr = plor_lyrs[plor_lyrnames.index(plor_lyrname)]
            if len(plor_lyr.selectedFeatures()) == 0:
                codouvgs = []
                for f in plor_lyr.getFeatures():
                    if f['CodeOuvrage'] not in codouvgs:
                        codouvgs.append(f['CodeOuvrage'])
                codouvgs.sort()
                codouvg, ctrl = QInputDialog.getItem(QInputDialog(), "CodeOuvrage PLOR", "Choisir le Code Ouvrage à tracer", codouvgs, 0)
                if ctrl :
                    # TODO: limiter sélection 1KM autour du zoom carte
                    plor_lyr.selectByExpression("CodeOuvrage='{0}'".format(codouvg))
            if len(plor_lyr.selectedFeatures()) > 0:
                if order_type == 'Ordonner par "Numero"' :
                    # ORDONNE LES POINTS PAR NUMERO
                    plf=plor_lyr.selectedFeatures()
                    plf.sort(key=lambda element: element['NumeroPoint'])
                    orderedid=[f.id() for f in plf]
                else :
                    # ORDONNE LES POINTS PAR PROXIMITE
                    maxdist, extremid, orderedid = 0, None, []
                    for f in plor_lyr.selectedFeatures():
                        for t in plor_lyr.selectedFeatures():
                            if t.id() != f.id() :
                                distance=t.geometry().distance(f.geometry())
                                # print(t.id(),f.id(),distance)
                                if distance > maxdist :
                                    maxdist = distance
                                    extremid = f.id()
                    # print(extremid)
                    orderedid.append(extremid)
                    while len(orderedid) < plor_lyr.selectedFeatureCount() :
                        mindist=99
                        for f in plor_lyr.selectedFeatures():
                            if f.id() not in orderedid :
                                distance=plor_lyr.getFeature(orderedid[-1]).geometry().distance(f.geometry())
                                # print(orderedid[-1],f.id(),distance)
                                if distance < mindist :
                                    mindist = distance
                                    extremid = f.id()
                        orderedid.append(extremid)
                        # print(extremid,orderedid)
                if len(orderedid) > 0 :
                    geom_line=QgsGeometry()
                    geom_line.addPoints([plor_lyr.getFeature(i).geometry().vertexAt(0) for i in orderedid], QgsWkbTypes.LineGeometry)
                    # print(geom_line)
                    #TODO previsualiser la ligne avant validation
                    line_lyr = line_lyrs[line_lyrnames.index(line_lyrname)]
                    #TODO créer des transactions automatiques
                    def createLine():
                        if not line_lyr.dataProvider().transaction():
                            self.messageBox('Critical', "Création abandonnée", "La création de la ligne ne peut aboutir", "Aucune session de mise à jour n'est ouverte")
                            return
                        elif line_lyr.dataProvider().transaction():
                            feat=QgsFeature(line_lyr.fields())
                            feat.setAttribute('id', str(uuid.uuid4()))
                            line_attrib = line_lyr.fields().names()
                            for attrib in [a for a in line_attrib if a not in ['ogr_pkid', 'pkid', 'id']] :
                                defvalue_lyr=line_lyr.fields().field(line_attrib.index(attrib)).defaultValueDefinition().expression().strip().strip("'").strip()
                                feat.setAttribute(attrib, defvalue_lyr)
                            valid=self.iface.openFeatureForm(line_lyr, feat)
                            if valid :
                                feat.setGeometry(geom_line)
                                result=line_lyr.addFeature(feat)
                                if result == True :
                                    self.iface.messageBar().pushMessage("Création réussie", Qgis.Success)
                                    # TODO : vider la sélection
                                    return
                                else:
                                    self.messageBox('Critical', "Création échouée", "La création ne peut aboutir")
                                    return
                    if not line_lyr.dataProvider().transaction():
                        self.iface.messageBar().pushMessage("Ouvrir la session de mise à jour", Qgis.Warning, duration=5)
                        QTimer.singleShot(5000, createLine)
                    else :
                        createLine()

    def getDatasourceGPKG(self) :
        gpkgs = []
        for layer in [l.layer() for l in self.root.findLayers() if l.layer().type() == QgsMapLayerType.VectorLayer] :
            if '.gpkg' in layer.dataProvider().uri().uri() :
                gpkg = layer.dataProvider().uri().uri().split('|')[0].strip()
                if gpkg not in gpkgs :
                    gpkgs.append(gpkg)
        return gpkgs

    def GPKG2GML(self) :
        print("GPKG2GML: run called!")
        gpkgs = self.getDatasourceGPKG()
        gpkg, ctrl = QInputDialog.getItem(QInputDialog(), "Geopackage vers GML", "Choisir le geopackage à exporter", gpkgs, 0)
        if ctrl :
            outputGML = QFileDialog.getSaveFileName(QFileDialog(), "Définir le fichier de destination", filter="GML (*.gml)")
            print(outputGML)
            if outputGML[0] :
                # dir_path = os.path.dirname(os.path.realpath(__file__))
                # print(dir_path)
                #TODO: calculer le chemin vers la XSD
                reseaulyr = self.getLayerFromTable('ReseauUtilite')
                reseaulyr.startEditing()
                reseaufeat = reseaulyr.getFeature(1)
                valid=self.iface.openFeatureForm(reseaulyr, reseaufeat)
                if valid :
                    result=reseaulyr.updateFeature(reseaufeat)
                    reseaulyr.commitChanges()
                else :
                    reseaulyr.rollBack()
                    self.iface.messageBar().pushMessage("Export abandonné", "Action annulée par l'utilisateur", Qgis.Warning, duration=5)
                    return
                param={}
                param['INPUT']=gpkg
                param['CONVERT_ALL_LAYERS']=True
                param['OPTIONS']='-f GMLAS -dsco INPUT_XSD="/Users/alicesalse/Documents/BMG/PROJETS/ENEDIS/OpenRecoStar/StaR-Elec/RecoStaR/SchemaStarElecRecoStarV0_6.xsd" -dsco SRSNAME_FORMAT=SHORT -dsco WRAPPING=GMLAS_FEATURECOLLECTION -dsco GENERATE_XSD=NO'
                param['OUTPUT']=outputGML[0]
                # print(param)
                output=processing.run("gdal:convertformat", param)
                self.iface.messageBar().pushMessage("Export terminé", output['OUTPUT'], Qgis.Success)
                return
