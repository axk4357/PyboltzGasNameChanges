from PyBoltz cimport PyBoltz
from libc.math cimport sin, cos, acos, asin, log, sqrt, pow
from libc.string cimport memset
from PyBoltz cimport drand48
from MBSorts cimport MBSort
import numpy as np
cimport numpy as np
from libc.stdlib cimport malloc, free
import cython

# The functionality of MONTEC mirrors MONTE.  The latter is more extensively documented in the code
#  and we refer developers there for more information.

@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cdef double random_uniform(double dummy):
    cdef double r = drand48(dummy)
    return r


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cpdef run(PyBoltz Object):
    """
    This function is used to calculates collision events and updates diffusion and velocity.Background gas motion included at temp =  TemperatureCentigrade.

    This function is used for any magnetic field electric field in the z direction.    
    
    The object parameter is the PyBoltz object to have the output results and to be used in the simulation.
    """
    cdef long long I, NumDecorLengths,  NumCollisions, IEXTRA, IMBPT, K, J, iCollisionM, iSample, iCollision, GasIndex, IE, IT, CollsToLookBack, IPT, iCorr, DecorDistance
    cdef double ST1, RandomSeed, ST2, SumE2, SumXX, SumYY, SumZZ, SumXZ, SumXY, Z_LastSample, ST_LastSample, ST1_LastSample, ST2_LastSample, SumZZ_LastSample, SumXX_LastSample, SumYY_LastSample, SumYZ_LastSample, SumXY_LastSample, SXZ_LastSample, SME2_LastSample, TDash
    cdef double ABSFAKEI, DirCosineZ1, DirCosineX1, DirCosineY1, VelXBefore, VelYBefore, VelZBefore, BP, F1, F2, TwoPi, DirCosineX2, DirCosineY2, DirCosineZ2, VelXAfter, VelYAfter, VelZAfter, DZCOM, DYCOM, DXCOM, Theta,
    cdef double  EBefore, Sqrt2M, TwoM, AP, CONST6, RandomNum, GasVelX, GasVelY, GasVelZ, VEX, VEY, VEZ, COMEnergy, Test1, Test2, Test3, VelBeforeM1
    cdef double T2, A, B, CONST7, S1, EI, R9, EXTRA, RAN, RandomNum1, CosTheta, EPSI, Phi, SinPhi, CosPhi, ARG1, D, Q, CosZAngle, U, CosSquareTheta, SinZAngle, VXLAB, VYLAB, VZLAB
    cdef double SumV_Samples, SumE_Samples, SumV2_Samples, SumE2_Samples, SumDXX_Samples, SumDYY_Samples, SumDZZ_Samples, TXCollY, TXCollZ, TYCollZ, SumDXX2_Samples, SumDYY2_Samples, SumDZZ2_Samples, T2XCollY, T2XCollZ, T2YCollZ, Attachment, Ionization, E, SumYZ, SumLS, SumTS
    cdef double SLN_LastSample, STR_LastSample, MeanEnergy_LastSample, EFZ100, EFX100, MeanEnergy, WZR, WYR, WXR, XR, ZR, YR, TDriftVelPerSampleY, TWCollX, T2DriftVelPerSampleY, T2WCollX,TEMP[4000]
    cdef double *CollT, *CollX, *CollY, *CollZ, *DriftVelPerSampleZ, *MeanEnergyPerSample, *DiffZZPerSample, *DiffYYPerSample, *DiffXXPerSample, *DiffYZPerSample, *DFXCollY, *DiffXZPerSample, *DriftVelPerSampleYZ, *WXCollZ
    cdef double DIFXXR, DIFYYR, DIFZZR, DIFYZR, DIFXZR, DIFXYR, ZR_LastSample, YR_LastSample, XR_LastSample, SumZZR, SumYYR, SumXXR, SumXYR, SXZR, RCS, RSN, RTHETA, EOVBR

    CollT = <double *> malloc(2000000 * sizeof(double))
    memset(CollT, 0, 2000000 * sizeof(double))
    CollX = <double *> malloc(2000000 * sizeof(double))
    memset(CollX, 0, 2000000 * sizeof(double))

    CollY = <double *> malloc(2000000 * sizeof(double))
    memset(CollY, 0, 2000000 * sizeof(double))

    CollZ = <double *> malloc(2000000 * sizeof(double))
    memset(CollZ, 0, 2000000 * sizeof(double))

    DriftVelPerSampleZ = <double *> malloc(10 * sizeof(double))
    memset(DriftVelPerSampleZ, 0, 10 * sizeof(double))

    DriftVelPerSampleY = <double *> malloc(10 * sizeof(double))
    memset(DriftVelPerSampleY, 0, 10 * sizeof(double))

    WCollX = <double *> malloc(10 * sizeof(double))
    memset(WCollX, 0, 10 * sizeof(double))

    MeanEnergyPerSample = <double *> malloc(10 * sizeof(double))
    memset(MeanEnergyPerSample, 0, 10 * sizeof(double))

    DiffZZPerSample = <double *> malloc(10 * sizeof(double))
    memset(DiffZZPerSample, 0, 10 * sizeof(double))

    DiffYYPerSample = <double *> malloc(10 * sizeof(double))
    memset(DiffYYPerSample, 0, 10 * sizeof(double))

    DiffXXPerSample = <double *> malloc(10 * sizeof(double))
    memset(DiffXXPerSample, 0, 10 * sizeof(double))

    DiffYZPerSample = <double *> malloc(10 * sizeof(double))
    memset(DiffYZPerSample, 0, 10 * sizeof(double))

    DFXCollY = <double *> malloc(10 * sizeof(double))
    memset(DFXCollY, 0, 10 * sizeof(double))

    DiffXZPerSample = <double *> malloc(10 * sizeof(double))
    memset(DiffXZPerSample, 0, 10 * sizeof(double))

    TEMP = <double *> malloc(4000 * sizeof(double))
    memset(TEMP, 0, 4000 * sizeof(double))
    for J in range(4000):
        TEMP[J] = Object.TotalCollisionFrequencyNullNT[J] + Object.TotalCollisionFrequencyNT[J]

    Object.VelocityX = 0.0
    Object.VelocityErrorX = 0.0
    Object.X = 0.0
    Object.Y = 0.0
    Object.Z = 0.0
    DIFXXR = 0.0
    DIFYYR = 0.0
    DIFZZR = 0.0
    DIFYZR = 0.0
    Object.TransverseDiffusion = 0.0
    Object.LongitudinalDiffusion = 0.0
    Object.LongitudinalDiffusionError = 0.0
    Object.TransverseDiffusionError = 0.0
    DIFXZR = 0.0
    DIFXYR = 0.0
    Object.TimeSum = 0.0
    ST1 = 0.0
    SumXX = 0.0
    SumYY = 0.0
    SumZZ = 0.0
    SumYZ = 0.0
    SumXY = 0.0
    SumXZ = 0.0
    ZR_LastSample = 0.0
    YR_LastSample = 0.0
    XR_LastSample = 0.0
    SumZZR = 0.0
    SumYYR = 0.0
    SumXXR = 0.0
    SumXYR = 0.0
    SumYZR = 0.0
    SXZR = 0.0
    ST_LastSample = 0.0
    ST1_LastSample = 0.0
    ST2_LastSample = 0.0
    SumZZ_LastSample = 0.0
    SumYY_LastSample = 0.0
    SumXX_LastSample = 0.0
    SumYZ_LastSample = 0.0
    SumXY_LastSample = 0.0
    SXZ_LastSample = 0.0

    MeanEnergy_LastSample = 0.0
    RCS = cos((Object.BField_Angle - 90) * np.pi / 180)
    RSN = sin((Object.BField_Angle - 90) * np.pi / 180)
    RTHETA = Object.BField_Angle * np.pi / 180
    EFZ100 = Object.EField * 100 * sin(RTHETA)
    EFX100 = Object.EField * 100 * cos(RTHETA)
    F1 = Object.EField * Object.CONST2 * cos(RTHETA)
    TwoPi = 2 * np.pi
    Sqrt2M = Object.CONST3 * 0.01
    EOVBR = Object.EFieldOverBField * sin(RTHETA)
    EBefore = Object.InitialElectronEnergy
    NumDecorLengths = 0
    NumCollisions = 0
    INTEM = 8
    IEXTRA = 0

    ABSFAKEI = Object.FakeIonizations
    Object.FakeIonizations = 0

    #INITIAL DIRECTION COSINES
    DirCosineZ1 = cos(Object.AngleFromZ)
    DirCosineX1 = sin(Object.AngleFromZ) * cos(Object.AngleFromX)
    DirCosineY1 = sin(Object.AngleFromZ) * sin(Object.AngleFromX)

    # INITIAL VELOCITY
    VelTotal = Sqrt2M * sqrt(EBefore)
    VelXBefore = DirCosineX1 * VelTotal
    VelYBefore = DirCosineY1 * VelTotal
    VelZBefore = DirCosineZ1 * VelTotal

    DELTAE = Object.Max_Electron_Energy / float(INTEM)
    iCollisionM = <long long>(Object.MaxNumberOfCollisions / Object.Num_Samples)
    if Object.Console_Output_Flag:
        print('{:^12s}{:^12s}{:^12s}{:^10s}{:^10s}{:^10s}{:^10s}{:^10s}{:^10s}{:^10s}'.format("Velocity Z", "Velocity Y", "Velocity X","Energy",
                                                                       "DIFXX", "DIFYY", "DIFZZ", "DIFYZ","DIFXZ","DIFXY"))
    for iSample in range(int(Object.Num_Samples)):
        for iCollision in range(int(iCollisionM)):
            while True:
                RandomNum = random_uniform(RandomSeed)
                I = int(EBefore / DELTAE) + 1
                I = min(I, INTEM) - 1
                TLIM = Object.MaxCollisionFreqNT[I]
                T = -1 * log(RandomNum) / TLIM + TDash
                TDash = T
                WBT = Object.AngularSpeedOfRotation * T
                CosWT = cos(WBT)
                SinWT = sin(WBT)
                DZ = (VelZBefore * SinWT + (EOVBR - VelYBefore) * (1 - CosWT)) / Object.AngularSpeedOfRotation
                DX = VelXBefore * T + F1 * T * T
                E = EBefore + DZ * EFZ100 + DX * EFX100
                IE = int(E / Object.ElectronEnergyStep)
                IE = min(IE, 3999)
                if TEMP[IE] > TLIM:
                    TDash += log(RandomNum) / TLIM
                    Object.MaxCollisionFreq[I] *= 1.05
                    continue

                RandomNum = random_uniform(RandomSeed)
                Test1 = Object.TotalCollisionFrequencyNT[IE] / TLIM

                # Test FOR REAL OR NULL COLLISION
                if RandomNum > Test1:
                    Test2 = TEMP[IE] / TLIM
                    if RandomNum < Test2:
                        if Object.NumMomCrossSectionPointsNullNT == 0:
                            continue
                        RandomNum = random_uniform(RandomSeed)
                        I = 0
                        while Object.NullCollisionFreqNT[IE][I] < RandomNum:
                            I += 1

                        Object.ICOLNNNT[I] += 1
                        continue
                    else:
                        Test3 = (TEMP[IE] + ABSFAKEI) / TLIM
                        if RandomNum < Test3:
                            # FAKE IONISATION INCREMENT COUNTER
                            Object.FakeIonizations += 1
                            continue
                        continue
                else:
                    break
            Object.MeanCollisionTime = 0.9 * Object.MeanCollisionTime + 0.1 * T

            T2 = T ** 2
            TDash = 0.0

            VelXAfter = VelXBefore + 2 * F1 * T
            VelYAfter = (VelYBefore - EOVBR) * CosWT + VelZBefore * SinWT + EOVBR
            VelZAfter = VelZBefore * CosWT - (VelYBefore - EOVBR) * SinWT
            VelTotal = sqrt(VelXAfter ** 2 + VelYAfter ** 2 + VelZAfter ** 2)
            DirCosineX2 = VelXAfter / VelTotal
            DirCosineY2 = VelYAfter / VelTotal
            DirCosineZ2 = VelZAfter / VelTotal
            NumCollisions += 1

            Object.X += DX
            Object.Y += EOVBR * T + ((VelYBefore - EOVBR) * SinWT + VelZBefore * (1 - CosWT)) / Object.AngularSpeedOfRotation
            Object.Z += DZ
            Object.TimeSum += T

            IT = int(T)
            IT = min(IT, 299)
            Object.CollisionTimes[IT] += 1
            Object.CollisionEnergies[IE] += 1
            Object.VelocityZ = Object.Z / Object.TimeSum
            Object.VelocityY = Object.Y / Object.TimeSum
            Object.VelocityX = Object.X / Object.TimeSum
            if iSample >= 2:
                CollsToLookBack = 0
                for J in range(int(Object.Decor_Lookbacks)):
                    DecorDistance = NumCollisions + CollsToLookBack
                    if DecorDistance > Object.Decor_Colls:
                        DecorDistance = DecorDistance - Object.Decor_Colls
                    ST1 += T
                    TDiff = Object.TimeSum - CollT[DecorDistance-1]
                    CollsToLookBack += Object.Decor_Step
                    SumZZ += ((Object.Z - CollZ[DecorDistance-1] - Object.VelocityZ * TDiff) ** 2) * T / TDiff
                    SumYY += ((Object.Y - CollY[DecorDistance-1] - Object.VelocityY * TDiff) ** 2) * T / TDiff
                    SumXX += ((Object.X - CollX[DecorDistance-1] - Object.VelocityX * TDiff) ** 2) * T / TDiff
                    SumYZ += (Object.Z - CollZ[DecorDistance-1] - Object.VelocityZ * TDiff) * (
                            Object.Y - CollY[DecorDistance-1] - Object.VelocityY * TDiff) * T / TDiff
                    SumXY += (Object.X - CollX[DecorDistance-1] - Object.VelocityX * TDiff) * (
                            Object.Y - CollY[DecorDistance-1] - Object.VelocityY * TDiff) * T / TDiff
                    SumXZ += (Object.X - CollX[DecorDistance-1] - Object.VelocityX * TDiff) * (
                            Object.Z - CollZ[DecorDistance-1] - Object.VelocityZ * TDiff) * T / TDiff
            CollX[NumCollisions-1] = Object.X
            CollY[NumCollisions-1] = Object.Y
            CollZ[NumCollisions-1] = Object.Z
            CollT[NumCollisions-1] = Object.TimeSum
            if NumCollisions >= Object.Decor_Colls:
                NumDecorLengths += 1
                NumCollisions = 0
            RandomNum = random_uniform(RandomSeed)

            I = MBSort(I, RandomNum, IE, Object)
            while Object.CollisionFrequencyNT[IE][I] < RandomNum:
                I += 1

            S1 = Object.RGasNT[I]
            EI = Object.EnergyLevelsNT[I]
            if Object.ElectronNumChangeNT[I] > 0:
                R9 = random_uniform(RandomSeed)
                EXTRA = R9 * (E - EI)
                EI = EXTRA + EI
                IEXTRA += <long long>(Object.NC0NT[I])
            IPT = <long long>(Object.InteractionTypeNT[I])
            Object.CollisionsPerGasPerTypeNT[int(IPT)] += 1
            Object.ICOLNNT[I] += 1
            if E < EI:
                EI = E - 0.0001

            if Object.Enable_Penning != 0:
                if Object.PenningFractionNT[0][I] != 0:
                    RAN = random_uniform(RandomSeed)
                    if RAN <= Object.PenningFractionNT[0][I]:
                        IEXTRA += 1
            S2 = (S1 ** 2) / (S1 - 1.0)

            RandomNum = random_uniform(RandomSeed)
            if Object.AngularModelNT[I] == 1:
                RandomNum1 = random_uniform(RandomSeed)
                CosTheta = 1.0 - RandomNum * Object.AngleCutNT[IE][I]
                if RandomNum1 > Object.ScatteringParameterNT[IE][I]:
                    CosTheta = -1 * CosTheta
            elif Object.AngularModelNT[I] == 2:
                EPSI = Object.ScatteringParameterNT[IE][I]
                CosTheta = 1 - (2 * RandomNum * (1 - EPSI) / (1 + EPSI * (1 - 2 * RandomNum)))
            else:
                CosTheta = 1 - 2 * RandomNum
            Theta = acos(CosTheta)
            RandomNum = random_uniform(RandomSeed)
            Phi = TwoPi * RandomNum
            SinPhi = sin(Phi)
            CosPhi = cos(Phi)
            ARG1 = 1 - S1 * EI / E
            ARG1 = max(ARG1, Object.SmallNumber)
            D = 1 - CosTheta * sqrt(ARG1)
            EBefore = E * (1 - EI / (S1 * E) - 2 * D / S2)
            EBefore = max(EBefore, Object.SmallNumber)
            Q = sqrt((E / EBefore) * ARG1) / S1
            Q = min(Q, 1)
            Object.AngleFromZ = asin(Q * sin(Theta))
            CosZAngle = cos(Object.AngleFromZ)
            U = (S1 - 1) * (S1 - 1) / ARG1
            CosSquareTheta = CosTheta * CosTheta
            if CosTheta < 0 and CosSquareTheta > U:
                CosZAngle = -1 * CosZAngle
            SinZAngle = sin(Object.AngleFromZ)
            DirCosineZ2 = min(DirCosineZ2, 1)
            VelTotal = Sqrt2M * sqrt(EBefore)
            ARGZ = sqrt(DirCosineX2 * DirCosineX2 + DirCosineY2 * DirCosineY2)
            if ARGZ == 0:
                DirCosineZ1 = CosZAngle
                DirCosineX1 = CosPhi * SinZAngle
                DirCosineY1 = SinPhi * SinZAngle
            else:
                DirCosineZ1 = DirCosineZ2 * CosZAngle + ARGZ * SinZAngle * SinPhi
                DirCosineY1 = DirCosineY2 * CosZAngle + (SinZAngle / ARGZ) * (DirCosineX2 * CosPhi - DirCosineY2 * DirCosineZ2 * SinPhi)
                DirCosineX1 = DirCosineX2 * CosZAngle - (SinZAngle / ARGZ) * (DirCosineY2 * CosPhi + DirCosineX2 * DirCosineZ2 * SinPhi)
            VelXBefore = DirCosineX1 * VelTotal
            VelYBefore = DirCosineY1 * VelTotal
            VelZBefore = DirCosineZ1 * VelTotal
        Object.VelocityZ *= 1e9
        Object.VelocityY *= 1e9
        Object.VelocityX *= 1e9

        WZR = Object.VelocityZ * RCS - Object.VelocityX * RSN
        WYR = Object.VelocityY
        WXR = Object.VelocityZ * RSN + Object.VelocityX * RCS
        ZR = Object.Z * RCS - Object.X * RSN
        YR = Object.Y
        XR = Object.Z * RSN + Object.X * RCS
        MeanEnergy = 0.0
        for IK in range(4000):
            MeanEnergy += Object.E[IK] * Object.CollisionEnergies[IK] / Object.TotalCollisionFrequencyNT[IK]
        Object.MeanElectronEnergy = MeanEnergy / Object.TimeSum
        DriftVelPerSampleZ[iSample] = (ZR - ZR_LastSample) / (Object.TimeSum - ST_LastSample) * 1e9
        DriftVelPerSampleY[iSample] = (YR - YR_LastSample) / (Object.TimeSum - ST_LastSample) * 1e9
        WCollX[iSample] = (XR - XR_LastSample) / (Object.TimeSum - ST_LastSample) * 1e9
        MeanEnergyPerSample[iSample] = (MeanEnergy - MeanEnergy_LastSample) / (Object.TimeSum - ST_LastSample)
        MeanEnergy_LastSample = MeanEnergy


        if iSample >= 2:
            Object.DiffusionX = 5e15 * SumXX / ST1
            Object.DiffusionY = 5e15 * SumYY / ST1
            Object.DiffusionZ = 5e15 * SumZZ / ST1
            Object.DiffusionXY = 5e15 * SumXY / ST1
            Object.DiffusionYZ = 5e15 * SumYZ / ST1
            Object.DiffusionXZ = 5e15 * SumXZ / ST1

            DIFXXR = Object.DiffusionX * RCS * RCS + Object.DiffusionZ * RSN * RSN + 2 * RCS * RSN * Object.DiffusionXZ
            DIFYYR = Object.DiffusionY
            DIFZZR = Object.DiffusionX * RSN * RSN + Object.DiffusionZ * RCS * RCS - 2 * RCS * RSN * Object.DiffusionXZ
            DIFXYR = RCS * Object.DiffusionXY + RSN * Object.DiffusionYZ
            DIFYZR = RSN * Object.DiffusionXY - RCS * Object.DiffusionYZ
            DIFXZR = (RCS * RCS - RSN * RSN) * Object.DiffusionXZ - RSN * RCS * (Object.DiffusionX - Object.DiffusionZ)

            SumXXR = SumXX * RCS * RCS + SumZZ * RSN * RSN + 2 * RCS * RSN * SumXZ
            SumYYR = SumYY
            SumZZR = SumXX * RSN * RSN + SumZZ * RCS * RCS - 2 * RCS * RSN * SumXZ
            SumXYR = RCS * SumXY + RSN * SumYZ
            SumYZR = RSN * SumXY - RCS * SumYZ
            SXZR = (RCS * RCS - RSN * RSN) * SumXZ - RSN * RCS * (SumXX - SumZZ)
        DiffZZPerSample[iSample] = 0.0
        DiffXXPerSample[iSample] = 0.0
        DiffYYPerSample[iSample] = 0.0
        DiffYZPerSample[iSample] = 0.0
        DiffXZPerSample[iSample] = 0.0
        DFXCollY[iSample] = 0.0
        if iSample > 1:
            DiffZZPerSample[iSample] = 5e15 * (SumZZ - SumZZ_LastSample) / (ST1 - ST1_LastSample)
            DiffXXPerSample[iSample] = 5e15 * (SumXX - SumXX_LastSample) / (ST1 - ST1_LastSample)
            DiffYYPerSample[iSample] = 5e15 * (SumYY - SumYY_LastSample) / (ST1 - ST1_LastSample)
            DiffYZPerSample[iSample] = 5e15 * (SumYZ - SumYZ_LastSample) / (ST1 - ST1_LastSample)
            DiffXZPerSample[iSample] = 5e15 * (SumXZ - SXZ_LastSample) / (ST1 - ST1_LastSample)
            DFXCollY[iSample] = 5e15 * (SumXY - SumXY_LastSample) / (ST1 - ST1_LastSample)
        ZR_LastSample = ZR
        YR_LastSample = YR
        XR_LastSample = XR
        ST_LastSample = Object.TimeSum
        ST1_LastSample = ST1
        SumZZ_LastSample = SumZZR
        SumYY_LastSample = SumYYR
        SumXX_LastSample = SumXXR
        SumXY_LastSample = SumXYR
        SumYZ_LastSample = SumYZR
        SXZ_LastSample = SXZR
        if Object.Console_Output_Flag:
            print('{:^12.1f}{:^12.1f}{:^12.1f}{:^10.1f}{:^10.1f}{:^10.1f}{:^10.1f}{:^10.1f}{:^10.1f}{:^10.1f}'.format(WZR,WYR,WXR,
                                                                                    Object.MeanElectronEnergy, DIFXXR, DIFYYR,
                                                                                    DIFZZR,DIFYZR,DIFXZR,DIFXYR))
    SumV_Samples = 0.0
    TDriftVelPerSampleY = 0.0
    TWCollX = 0.0
    SumE_Samples = 0.0
    SumV2_Samples = 0.0
    T2DriftVelPerSampleY = 0.0
    T2WCollX = 0.0
    SumE2_Samples = 0.0
    SumDZZ_Samples = 0.0
    SumDYY_Samples = 0.0
    SumDXX_Samples = 0.0
    TXCollY = 0.0
    TXCollZ = 0.0
    TYCollZ = 0.0
    SumDZZ2_Samples = 0.0
    SumDYY2_Samples = 0.0
    SumDXX2_Samples = 0.0
    T2XCollY = 0.0
    T2XCollZ = 0.0
    T2YCollZ = 0.0

    for K in range(10):
        SumV_Samples = SumV_Samples + DriftVelPerSampleZ[K]
        TDriftVelPerSampleY = TDriftVelPerSampleY + DriftVelPerSampleY[K]
        TWCollX = TWCollX + WCollX[K]
        SumE_Samples = SumE_Samples + MeanEnergyPerSample[K]
        SumV2_Samples = SumV2_Samples + DriftVelPerSampleZ[K] * DriftVelPerSampleZ[K]
        T2DriftVelPerSampleY = T2DriftVelPerSampleY + DriftVelPerSampleY[K] * DriftVelPerSampleY[K]
        T2WCollX = T2WCollX + WCollX[K] * WCollX[K]
        SumE2_Samples = SumE2_Samples + MeanEnergyPerSample[K] * MeanEnergyPerSample[K]
        if K >= 2:
            SumDZZ_Samples = SumDZZ_Samples + DiffZZPerSample[K]
            SumDYY_Samples = SumDYY_Samples + DiffYYPerSample[K]
            SumDXX_Samples = SumDXX_Samples + DiffXXPerSample[K]
            TYCollZ = TYCollZ + DiffYZPerSample[K]
            TXCollY = TXCollY + DFXCollY[K]
            TXCollZ = TXCollZ + DiffXZPerSample[K]

            SumDZZ2_Samples += DiffZZPerSample[K] ** 2
            SumDXX2_Samples += DiffXXPerSample[K] ** 2
            SumDYY2_Samples += DiffYYPerSample[K] ** 2
            T2YCollZ += DiffYZPerSample[K] ** 2
            T2XCollY += DFXCollY[K] ** 2
            T2XCollZ += DiffXZPerSample[K] ** 2
    Object.VelocityErrorZ = 100 * sqrt((SumV2_Samples - SumV_Samples * SumV_Samples / Object.Num_Samples) / (Object.Num_Samples - 1)) / WZR
    Object.VelocityErrorY = 100 * sqrt((T2DriftVelPerSampleY - TDriftVelPerSampleY * TDriftVelPerSampleY / Object.Num_Samples) / (Object.Num_Samples - 1)) / abs(WYR)
    Object.VelocityErrorX = 100 * sqrt((T2WCollX - TWCollX * TWCollX / Object.Num_Samples) / (Object.Num_Samples - 1)) / abs(WXR)
    Object.MeanElectronEnergyError = 100 * sqrt((SumE2_Samples - SumE_Samples * SumE_Samples / Object.Num_Samples) / (Object.Num_Samples - 1)) / Object.MeanElectronEnergy
    Object.ErrorDiffusionZ = 100 * sqrt((SumDZZ2_Samples - SumDZZ_Samples * SumDZZ_Samples / (Object.Num_Samples - 2)) / (Object.Num_Samples - 3)) / DIFZZR
    Object.ErrorDiffusionY = 100 * sqrt((SumDYY2_Samples - SumDYY_Samples * SumDYY_Samples / (Object.Num_Samples - 2)) / (Object.Num_Samples - 3)) / DIFYYR
    Object.ErrorDiffusionX = 100 * sqrt((SumDXX2_Samples - SumDXX_Samples * SumDXX_Samples / (Object.Num_Samples - 2)) / (Object.Num_Samples - 3)) / DIFXXR
    Object.ErrorDiffusionXY = 100 * sqrt((T2XCollY - TXCollY * TXCollY / (Object.Num_Samples - 2)) / (Object.Num_Samples - 3)) / abs(DIFXYR)
    Object.ErrorDiffusionXZ = 100 * sqrt((T2XCollZ - TXCollZ * TXCollZ / (Object.Num_Samples - 2)) / (Object.Num_Samples - 3)) / abs(DIFXZR)
    Object.ErrorDiffusionYZ = 100 * sqrt((T2YCollZ - TYCollZ * TYCollZ / (Object.Num_Samples - 2)) / (Object.Num_Samples - 3)) / abs(DIFYZR)

    Object.VelocityErrorZ = Object.VelocityErrorZ / sqrt(Object.Num_Samples)
    Object.VelocityErrorX = Object.VelocityErrorX / sqrt(Object.Num_Samples)
    Object.VelocityErrorY = Object.VelocityErrorY / sqrt(Object.Num_Samples)
    Object.MeanElectronEnergyError = Object.MeanElectronEnergyError / sqrt(Object.Num_Samples)
    Object.ErrorDiffusionX = Object.ErrorDiffusionX / sqrt((Object.Num_Samples - 2))
    Object.ErrorDiffusionY = Object.ErrorDiffusionY / sqrt((Object.Num_Samples - 2))
    Object.ErrorDiffusionZ = Object.ErrorDiffusionZ / sqrt((Object.Num_Samples - 2))
    Object.ErrorDiffusionYZ = Object.ErrorDiffusionYZ / sqrt((Object.Num_Samples - 2))
    Object.ErrorDiffusionXY = Object.ErrorDiffusionXY / sqrt((Object.Num_Samples - 2))
    Object.ErrorDiffusionXZ = Object.ErrorDiffusionXZ / sqrt((Object.Num_Samples - 2))

    Object.VelocityZ = WZR
    Object.VelocityX = WXR
    Object.VelocityY = WYR
    Object.DiffusionX = DIFXXR
    Object.DiffusionY = DIFYYR
    Object.DiffusionZ = DIFZZR
    Object.DiffusionYZ = DIFYZR
    Object.DiffusionXY = DIFXYR
    Object.DiffusionXZ = DIFXZR

    Object.VelocityZ *= 1e5
    Object.VelocityY *= 1e5
    Object.VelocityX *= 1e5


    Attachment = 0.0
    Ionization = 0.0
    for I in range(Object.NumberOfGases):
        Attachment += Object.CollisionsPerGasPerTypeNT[5 * (I + 1) - 3]
        Ionization += Object.CollisionsPerGasPerTypeNT[5 * (I + 1) - 4]
    Ionization += IEXTRA
    Object.AttachmentRateError = 0.0
    if Attachment != 0:
        Object.AttachmentRateError = 100 * sqrt(Attachment) / Attachment
    Object.AttachmentRate = Attachment / (Object.TimeSum * Object.VelocityZ) * 1e12
    Object.IonisationRateError = 0.0
    if Ionization != 0:
        Object.IonisationRateError = 100 * sqrt(Ionization) / Ionization
    Object.IonisationRate = Ionization / (Object.TimeSum * Object.VelocityZ) * 1e12

    return

