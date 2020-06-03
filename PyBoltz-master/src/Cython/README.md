# Cython directory

In this directory exists the PyBoltz object, Gas object, Gasmix object, Ang object, Energylimits module, Setups module, Setup_npy module, Mixers module, PyBoltzRun module, Gases module, the Monte module.

## PyBoltz object

This is the main object, hence the name PyBoltz. In this object all the input, output, and intermediate parameters are stored. This object's functions coordinate the correct use of the modules. To eleaborate, after setting up the PyBoltz with the input parameters, the PyBoltz object calls the functions that correspond to the given input.

## Gas object

This object is a C struct that has the input and output parameters of a gas functions. A C struct was used for this object to save processing time. Some output parameters include the Cross sections, and the energy levels. Some of the input parameters include the final electron energy and the energy step. 

## Gasmix object 

This object is used to call the correct gas functions. This object consists mainly of an array of Gas objects and a dictionary of extra parameters. The extra parameters are used for special gas functions that require extra input. For example, the xenon MERT function. 

## Ang object

This object is used to set angle cuts on angular distribution and renormalise forward scattering probability.

## Energylimits modules 

This modules has the energy limits functions for the different input parameters. 

## Setups module
This module has a single function that is used to setup the constants needed for the simulation. 

## Setup_npy module

This modules has all the cross sections of all the gases. After running this file it will generate a gases.npy file which is used by the gas functions to get their respective cross sections. 

## Mixers module 
This module has the Mixing functions. In those functions the Gasmix object is used to run the gas functions. After doing so the Mixing functions use the output to calculate the collision frequencies that are needed for the simulation.

## PyBoltzRun
This modules is a wrapper build to ease the use of PyBoltz. Check the Examples/Example.py file for a usage example.

## Gases module 

This module contains all gas functions in PyBoltz.

## Monte module 

This module has all the Monte carlo functions used in PyBoltz.
