// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract GradesPool {

    struct Student{
        address studentAddress;
        uint256 grade;
    }

    struct Pool {
        uint256 poolValue;
        bool finishedBetting;
        uint256 numOfGrades;
    }

    Pool[] pools;
    mapping(uint => Student[]) indexToStudents;

    error TransactionHasNoValue();
    error IndexNotValid();
    error BettingClosed();
    error StudentDoesntExist();
    error GradeMustBeBelow100();
    error TransactionFailed();

    modifier IndexExists(uint256 _index) {
        if(pools.length < _index){
            revert IndexNotValid();
        }
        _;
    }

    function newPool() external payable {
        if(msg.value == 0) {
            revert TransactionHasNoValue();
        }
        
        pools.push(Pool(msg.value, false, 0));
    }

    function bet(uint256 _index) external payable IndexExists(_index){
        if(msg.value == 0) {
            revert TransactionHasNoValue();
        }

        if(pools[_index].finishedBetting){
            revert BettingClosed();
        }

        for(uint x; x < indexToStudents[_index].length; x++){
            if(indexToStudents[_index][x].studentAddress == msg.sender){
                pools[_index].poolValue += msg.value;
                return;
            }
        }

        indexToStudents[_index].push(Student(msg.sender, 0));
        pools[_index].poolValue += msg.value;
    }

    function postGrade(uint256 _index, uint256 _grade) external IndexExists(_index) {
        if(!pools[_index].finishedBetting){
            pools[_index].finishedBetting = true;
        }

        if(_grade > 100){
            revert GradeMustBeBelow100();
        }

        for(uint x; x < indexToStudents[_index].length; x++){
            if(indexToStudents[_index][x].studentAddress == msg.sender){
                indexToStudents[_index][x].grade = _grade;
                pools[_index].numOfGrades++;

                if(pools[_index].numOfGrades == indexToStudents[_index].length){
                    executeDistribution(_index);
                }
            }
        }

        revert StudentDoesntExist();
    }

    function executeDistribution(uint256 _index) internal {
        uint256 highestGrade;
        uint256 indexOfHighestGrade;

        for(uint x; x < indexToStudents[_index].length; x++){
            if(indexToStudents[_index][x].grade > highestGrade){
                highestGrade = indexToStudents[_index][x].grade;
                indexOfHighestGrade = _index;
            }
        }

        (bool success, ) = indexToStudents[_index][indexOfHighestGrade].studentAddress.call{value: pools[_index].poolValue}("");

        if(!success){
            revert TransactionFailed();
        }
    }  
}
