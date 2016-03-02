# -*- coding: utf-8 -*-
"""
Created on Wed Feb 10 17:47:09 2016

Run a "wizard"-based particle tracking app.

@author: rwb27
"""

from nplab.utils.gui import QtCore, QtGui, uic, get_qt_app
import os

# Load the wizard interface from the UI file
TrackingWizard, QWizard =  uic.loadUiType(os.path.join(os.path.dirname(__file__), 'wizard.ui'))

if __name__ == '__main__':
    app = get_qt_app()
    
    wizard = TrackingWizard()
    