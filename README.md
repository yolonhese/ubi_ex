# Exercise 2.1 - Therapy
Functions' purpose, arguments and returns are documented in the `therapy.sol` source file. 

After deploying the `Clinics` contract, a new `TherapySchedule`contract will be deployed by the constructor with Maria's ownership implemented.

## Clinics

Serves as a factory and a wrapper around the whole ecosystem. All transactions are done through this contract.

The objective was to make a boilerplate proxy for the contract mutability of the next exercise. There is still a better separation of concerns regarding data persistance and logic in order to achieve the goal.

## Therapy

Is the data structure and functionality basis for a single therapy session schedule.

Is important to note that workers are never deleted from the sytem. When fired, their info is updated to reflect the event. This is important to maintein the data integrity.


# Exercise 2.2 - PiggyBank

Functions' purpose, arguments and returns are documented in the `piggybank.sol` source file.

# Multi Sign System

After the `PiggyBank` contract deployment, once a deposit is made, the origin account is added to the stakeholders list.

# Mutability

Missing, not implemented. Tried to do something that was pre-made library agnostic, but was unable to achieve the result due to time contraints.