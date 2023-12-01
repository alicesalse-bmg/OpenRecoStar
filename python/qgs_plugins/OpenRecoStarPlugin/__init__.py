# -*- coding: utf-8 -*-
def classFactory(iface):
  from .mainPlugin import RecoStarTools
  return RecoStarTools(iface)

## any other initialisation needed
