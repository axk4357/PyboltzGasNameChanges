from Gases.CF4 cimport Gas_cf4
from Gases.ARGON cimport Gas_argon
from Gases.HELIUM4 cimport Gas_helium4
from Gases.HELIUM3 cimport Gas_helium3
from Gases.NEON cimport Gas_neon
from Gases.KRYPTON cimport Gas_krypton
from Gases.XENON cimport Gas_xenon
from Gases.CH4 cimport Gas_ch4
from Gases.ETHANE cimport Gas_ethane
from Gases.PROPANE cimport Gas_propane
from Gases.ISOBUTANE cimport Gas_isobutane
from Gases.CO2 cimport Gas_co2
from Gases.H2O cimport Gas_h2o
from Gases.OXYGEN cimport Gas_oxygen
from Gases.NITROGEN cimport Gas_nitrogen
from Gases.HYDROGEN cimport Gas_hydrogen
from Gases.DEUTERIUM cimport Gas_deuterium
from Gases.DME cimport Gas_DME
from Gases.XENONMERT cimport Gas_xenonmert
from libc.string cimport memset
from Gas cimport Gas

cdef void callGASF(Gas*GAS, Params):
    if GAS.GasNumber == 1:
        Gas_cf4(GAS)
    elif GAS.GasNumber == 2:
        Gas_argon(GAS)
    elif GAS.GasNumber == 3:
        Gas_helium4(GAS)
    elif GAS.GasNumber == 4:
        Gas_helium3(GAS)
    elif GAS.GasNumber == 5:
        Gas_neon(GAS)
    elif GAS.GasNumber == 6:
        Gas_krypton(GAS)
    elif GAS.GasNumber == 7:
        Gas_xenon(GAS)
    elif GAS.GasNumber == 8:
        Gas_ch4(GAS)
    elif GAS.GasNumber == 9:
        Gas_ethane(GAS)
    elif GAS.GasNumber == 10:
        Gas_propane(GAS)
    elif GAS.GasNumber == 11:
        Gas_isobutane(GAS)
    elif GAS.GasNumber == 12:
        Gas_co2(GAS)
    elif GAS.GasNumber == 14:
        Gas_h2o(GAS)
    elif GAS.GasNumber == 15:
        Gas_oxygen(GAS)
    elif GAS.GasNumber == 16:
        Gas_nitrogen(GAS)
    elif GAS.GasNumber == 21:
        Gas_hydrogen(GAS)
    elif GAS.GasNumber == 22:
        Gas_deuterium(GAS)
    elif GAS.GasNumber == 25:
        Gas_DME(GAS)
    elif GAS.GasNumber == 61:
        Gas_xenonmert(GAS, Params['A'], Params['D'], Params['F'], Params['A1'], Params['Lambda'], Params['EV0'])

cdef class Gasmix:
    """
    The Gasmix object is used to coordinate the calling of different gas functions. It contains an array of six Gas object structs.
    This object is used by the Mixer functions to get the cross section outputs.
    """

    def InitWithInfo(self, GasNumber, InelasticCrossSectionPerGas, N_Inelastic, PenningFraction, EG, SqrtEnergy,
                     NumberOfGases, EnergySteps,
                     WhichAngularModel, EnergyStep, FinalEnergy, ThermalEnergy, TemperatureC, Pressure, PIR2,
                     RhydbergConst):
        '''This functions simply initiates the gas data from the parameters. This functions fills the output arrays to zeros.'''
        cdef int i, j;
        for i in range(6):
            self.Gases[i].GasNumber = GasNumber[i]
            for j in range(250):
                self.Gases[i].InelasticCrossSectionPerGas[j][:] = InelasticCrossSectionPerGas[i][j]
            self.Gases[i].N_Inelastic = N_Inelastic[i]
            for j in range(3):
                self.Gases[i].PenningFraction[j][:] = PenningFraction[i][j]
            self.Gases[i].EG = EG
            self.Gases[i].SqrtEnergy = SqrtEnergy
            self.Gases[i].NumberOfGases = NumberOfGases
            self.Gases[i].EnergySteps = EnergySteps
            self.Gases[i].WhichAngularModel = WhichAngularModel
            self.Gases[i].FinalEnergy = FinalEnergy
            self.Gases[i].ThermalEnergy = ThermalEnergy
            self.Gases[i].EnergyStep = EnergyStep
            self.Gases[i].TemperatureC = TemperatureC
            self.Gases[i].Pressure = Pressure
            self.Gases[i].PIR2 = PIR2
            self.Gases[i].RhydbergConst = RhydbergConst
            memset(self.Gases[i].Q, 0, 6 * 4000 * sizeof(double))
            memset(self.Gases[i].IonizationCrossSection, 0, 30 * 4000 * sizeof(double))
            memset(self.Gases[i].PEIonizationCrossSection, 0, 30 * 4000 * sizeof(double))
            memset(self.Gases[i].AttachmentCrossSection, 0, 8 * 4000 * sizeof(double))
            memset(self.Gases[i].NullCrossSection, 0, 10 * 4000 * sizeof(double))

    def reset(self):
        '''Function used to zero out the main output arrays.'''
        for i in range(6):
            memset(self.Gases[i].Q, 0, 6 * 4000 * sizeof(double))
            memset(self.Gases[i].IonizationCrossSection, 0, 30 * 4000 * sizeof(double))
            memset(self.Gases[i].PEIonizationCrossSection, 0, 30 * 4000 * sizeof(double))
            memset(self.Gases[i].AttachmentCrossSection, 0, 8 * 4000 * sizeof(double))
            memset(self.Gases[i].NullCrossSection, 0, 10 * 4000 * sizeof(double))

    def Run(self):
        '''This functions calls the corresponding gas functions.'''
        cdef int i
        cdef Gas temp
        for i in range(6):
            callGASF(&self.Gases[i], self.ExtraParameters)
