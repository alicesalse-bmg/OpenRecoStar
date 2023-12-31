from qgis.PyQt.QtGui import *
from qgis.PyQt.QtWidgets import *
from qgis.PyQt.QtSql import *
from qgis.PyQt.QtCore import *
from qgis.utils import Qgis
from qgis.core import QgsProject, QgsDataSourceUri, QgsWkbTypes, QgsMapLayerType, QgsFeature, QgsLayerTreeGroup, QgsLayerTreeLayer, QgsFieldConstraints, QgsEditorWidgetSetup, QgsDefaultValue, QgsVectorLayer, QgsPoint, QgsGeometry, QgsCoordinateTransform, QgsCoordinateReferenceSystem
# initialize Qt resources from file resources.py
# execute : pyrcc5 -o resources.py resources.qrc
from . import resources
import uuid

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
        self.ordertyp.addItems(['Ordonner par "Numero"', 'Ordonner par proximité'])
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
                            for attrib in [a for a in plor_attrib if a not in ['pkid', 'id']] :
                                attrib_stp = plor_lyr.editorWidgetSetup(plor_attrib.index(attrib))
                                # print(attrib, attrib_stp.config())
                                if attrib_stp.type() == 'ValueRelation':
                                    value_lyr = self.root.findLayer(attrib_stp.config()['Layer']).layer()
                                    value_list = [f['valeurs'] for f in value_lyr.getFeatures()]
                                    formlayout[attrib] = ('ComboBox',self.sortsimilarity(attrib, vlyr_attrib)+['<AUTRE>'],value_list)
                                else :
                                    defvalue_lyr=plor_lyr.fields().field(plor_attrib.index(attrib)).defaultValueDefinition().expression().strip().strip("'").strip()
                                    formlayout[attrib] = ('ComboBox',self.sortsimilarity(attrib, vlyr_attrib)+['<AUTRE>'],defvalue_lyr) # TODO ajouter des infos sur le type d'attribut
                            if file_type == 'csv' :
                                formlayout['GeomX'] = ('ComboBox',self.sortsimilarity('X', vlyr_attrib),None)
                                formlayout['GeomY'] = ('ComboBox',self.sortsimilarity('Y', vlyr_attrib),None)
                                formlayout['GeomZ'] = ('ComboBox',self.sortsimilarity('Z', vlyr_attrib),None)
                                formlayout['GeomEPSG'] = ('ComboBox', ['2154','3950','3949','3948','3847','3946','3945','3944','3943','3942','27561','27562','27563','27564','27571','27572','27573','27574','<AUTRE>'],None)
                            dial = MappingDialogBox("Import fichier PLOR", formlayout, self)
                            if dial.exec() == QDialog.Accepted:
                                mapping=dial.get_output()
                                print(mapping)
                                for vfeat in vlayer.getFeatures() :
                                    pfeat=QgsFeature(plor_lyr.fields())
                                    pfeat.setAttribute('id', str(uuid.uuid4()))
                                    for m in mapping :
                                        if (file_type == 'csv' and m[:4] != 'Geom') or file_type != 'csv' :
                                            if mapping[m][0] == "'" and mapping[m][-1] == "'":
                                                pfeat.setAttribute(m, mapping[m].strip("'"))
                                            else :
                                                pfeat.setAttribute(m, vfeat.attribute(mapping[m]))
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
        return [n for n, s in newlist]

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
                # TODO : option pour trier par numero plutot que de proche en proche

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
                    def createLine():
                        if not line_lyr.dataProvider().transaction():
                            self.messageBox('Critical', "Création abandonnée", "La création de la ligne ne peut aboutir", "Aucune session de mise à jour n'est ouverte")
                            return
                        elif line_lyr.dataProvider().transaction():
                            feat=QgsFeature(line_lyr.fields())
                            feat.setAttribute('id', str(uuid.uuid4()))
                            line_attrib = line_lyr.fields().names()
                            for attrib in [a for a in line_attrib if a not in ['pkid', 'id']] :
                                defvalue_lyr=line_lyr.fields().field(line_attrib.index(attrib)).defaultValueDefinition().expression().strip().strip("'").strip()
                                feat.setAttribute(attrib, defvalue_lyr)
                            valid=self.iface.openFeatureForm(line_lyr, feat)
                            if valid :
                                feat.setGeometry(geom_line)
                                result=line_lyr.addFeature(feat)
                                if result == True :
                                    self.iface.messageBar().pushMessage("Création réussie", Qgis.Success)
                                    return
                                else:
                                    self.messageBox('Critical', "Création échouée", "La création ne peut aboutir")
                                    return
                    if not line_lyr.dataProvider().transaction():
                        self.iface.messageBar().pushMessage("Ouvrir la session de mise à jour", Qgis.Warning, duration=5)
                        QTimer.singleShot(5000, createLine)
                    else :
                        createLine()
