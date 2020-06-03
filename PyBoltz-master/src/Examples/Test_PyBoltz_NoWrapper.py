import sys
import warnings
from pathlib import Path
import time
warnings.filterwarnings("ignore", message="numpy.dtype size changed")
warnings.filterwarnings("ignore", message="numpy.ufunc size changed")
#print(sys.path)
from PyBoltz import PyBoltz
import numpy as np
# Setup gases
exec(Path("../Cython/Setup_npy.py").read_text())

CF4 = 1
He4 = 3
He3 = 4
Ne  = 5
Kr  = 6
Xe  = 7
CH4 = 8
ETHANE = 9
PROPANE = 10
ISOBUTANE = 11
CO2 = 12
H2O = 14
O2 = 15
N2 = 16
H2 = 21
DEUTERIUM = 22
DME = 24

GASES = [np.nan, 'CF4', 'ARGON', 'HELIUM4', 'HELIUM3', 'NEON', 'KRYPTON', 'XENON', 'CH4', 'ETHANE', 'PROPANE'
         , 'ISOBUTANE', 'CO2', np.nan, 'H2O', 'OXYGEN', 'NITROGEN', np.nan, np.nan, np.nan, np.nan
         , 'HYDROGEN', 'DEUTERIUM', np.nan, np.nan, 'DME']

Object = PyBoltz()

import time
t1 =time.time()

# Set the number of gases
Object.NumberOfGases =1
# Set the number of collisons
Object.MaxNumberOfCollisions =1*40000000.0
# Set penning
Object.Enable_Penning = 0
# Calculate the electron energy
Object.Enable_Thermal_Motion=1
Object.Max_Electron_Energy = 0.0
# Set the gas's with there given number
Object.GasIDs=[15,0,0,0,0,0]
# Set the gas fractions
Object.GasFractions=[100,0,0,0,0,0]
# Set the tempature
Object.TemperatureCentigrade = float(23)
# Set the pressure
Object.Pressure_Torr = 750.062
# Set the eletric field
Object.EField = 100000
# Set the magnetic field and angle
Object.BField_Mag =0
Object.BField_Angle =0
Object.Console_Output_Flag = 1
Object.Steady_State_Threshold = 40
Object.Which_Angular_Model = 2


Object.Start()

t2 =time.time()

print("************************************************")
print("************************************************")
print("*****         Here are the outputs         *****")
print("************************************************ \n")
print("run time [s]= ",round(t2-t1,3))

for I in range(Object.NumberOfGases):
    if Object.GasIDs[I]<=25:
        print("Percentage of "+GASES[int(Object.GasIDs[I])]+" = "+  str(Object.GasFractions[I]))

print("Tempature [C]         = ", Object.TemperatureCentigrade)
print("Pressure [torr]       = ", Object.Pressure_Torr)
print("Eletric field [V/cm]  = ", Object.EField)
print("----------------------------------------------------")
print("Drift velocity [mm/mus]              = ", round(Object.VelocityZ,3))
print("----------------------------------------------------")
print("Drift velocity error [%]             = ", round(Object.VelocityErrorZ,3))
print("----------------------------------------------------")
print("Transverse diffusion [cm**2/s]       = ", round(Object.TransverseDiffusion,3))
print("----------------------------------------------------")
print("Transverse diffusion error [%]       = ", round(Object.TransverseDiffusionError,3))
print("----------------------------------------------------")
print("Longitudinal diffusion [cm**2/s]     = ", round(Object.LongitudinalDiffusion,3))
print("----------------------------------------------------")
print("Longitudinal diffusion error [%]     = ", round(Object.LongitudinalDiffusionError,3))
print("----------------------------------------------------")
print("Transverse diffusion [mum/cm**0.5]   = ", round(Object.TransverseDiffusion1,3))
print("----------------------------------------------------")
print("Transverse diffusion error [%]       = ", round(Object.TransverseDiffusion1Error,3))
print("----------------------------------------------------")
print("Longitudinal diffusion [mum/cm**0.5] = ", round(Object.LongitudinalDiffusion1,3))
print("----------------------------------------------------")
print("Longitudinal diffusion error [%]     = ", round(Object.LongitudinalDiffusion1Error,3))
print("----------------------------------------------------")
print("Diffusion X [cm**2/s]       = ", round(Object.DiffusionX,3))
print("----------------------------------------------------")
print("Diffusion X error [%]     = ", round(Object.ErrorDiffusionX,3))
print("----------------------------------------------------")
print("Diffusion Y [cm**2/s]       = ", round(Object.DiffusionY,3))
print("----------------------------------------------------")
print("Diffusion Y error [%]     = ", round(Object.ErrorDiffusionY,3))
print("----------------------------------------------------")
print("Diffusion Z [cm**2/s]       = ", round(Object.DiffusionZ,3))
print("----------------------------------------------------")
print("Diffusion Z error [%]     = ", round(Object.ErrorDiffusionZ,3))
print("----------------------------------------------------")
print("Diffusion YZ [cm**2/s]       = ", round(Object.DiffusionYZ,3))
print("----------------------------------------------------")
print("Diffusion YZ error [%]     = ", round(Object.ErrorDiffusionYZ,3))
print("----------------------------------------------------")
print("Diffusion XY [cm**2/s]       = ", round(Object.DiffusionXY,3))
print("----------------------------------------------------")
print("Diffusion XY error [%]     = ", round(Object.ErrorDiffusionXY,3))
print("----------------------------------------------------")
print("Diffusion XZ [cm**2/s]       = ", round(Object.DiffusionXZ,3))
print("----------------------------------------------------")
print("Diffusion XZ error [%]     = ", round(Object.ErrorDiffusionXZ,3))
print("----------------------------------------------------")
print("Mean electron energy [eV]            = ", round(Object.MeanElectronEnergy,3))
print("----------------------------------------------------")
print("Mean electron energy error [%]       = ", round(Object.MeanElectronEnergyError,3))
print("----------------------------------------------------")
print("Mean Collision Time [PicoSeconds]    = ", round(Object.MeanCollisionTime,3))
print("----------------------------------------------------")
print("Ionisation Rate [1/cm]               = ", round(Object.IonisationRate,3))
print("----------------------------------------------------")
print("Attachment Rate [1/cm]               = ", round(Object.AttachmentRate,3))
print("----------------------------------------------------")
print("************************************************")
print("************************************************")

