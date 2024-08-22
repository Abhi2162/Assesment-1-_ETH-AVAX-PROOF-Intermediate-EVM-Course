# Assesment 3.1- Skill based task market System
A Decentralized Skill-Based Task Market System is a blockchain-based application designed to manage tasks in a transparent, secure, and decentralized manner. The core idea is to leverage the properties of blockchain technology, such as immutability, transparency, and decentralization, to create a task marketplace that operates without centralized control or manipulation. Employers can list tasks, and workers can claim, complete, and receive rewards for them, all within a secure and trustless environment. This system ensures fair and transparent management of tasks and rewards, fostering trust between employers and workers.

## Description
The Skill Based Task Market system  smart contract is a decentralized platform where employers can list tasks, and workers can claim, complete, and earn rewards for them. Each task includes a description, reward amount, employer and worker addresses, and a completion status. The contract has functions for creating tasks, claiming them by workers, marking them as completed, and claiming rewards. It ensures that only the assigned worker can complete a task and claim the reward, while also providing a way to check the task details. This system allows tasks to be managed and rewards distributed in a secure and transparent manner.

## Getting Started

### Executing Program
To execute this program you can go to the Remix IDE which is open IDE for Solidity. For that you can click on this link https://remix.ethereum.org/

Once you successfully reached to the IDE create a new file by clicking on the '+' icon and saving that file with .sol extension (e.g. skillbasedtaskmarket.sol). After this copy and paste the code in your file that is given below 

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillBasedTaskMarket {
    struct Task {
        string description;
        uint256 reward;
        address employer;
        address worker;
        bool isCompleted;
    }

    uint256 public taskCount;
    mapping(uint256 => Task) public tasks;

    event TaskCreated(uint256 taskId, string description, uint256 reward, address employer);
    event TaskClaimed(uint256 taskId, address worker);
    event TaskCompleted(uint256 taskId, address worker);
    event RewardClaimed(uint256 taskId, address worker, uint256 reward);

    modifier onlyEmployer(uint256 taskId) {
        require(tasks[taskId].employer == msg.sender, "Only the employer can perform this action.");
        _;
    }

    modifier onlyWorker(uint256 taskId) {
        require(tasks[taskId].worker == msg.sender, "Only the assigned worker can perform this action.");
        _;
    }

    modifier taskExists(uint256 taskId) {
        require(taskId > 0 && taskId <= taskCount, "Task does not exist.");
        _;
    }

    modifier notCompleted(uint256 taskId) {
        require(!tasks[taskId].isCompleted, "Task is already completed.");
        _;
    }

    function createTask(string memory description) public payable {
        require(msg.value > 0, "Task reward must be greater than zero.");

        taskCount++;
        tasks[taskCount] = Task({
            description: description,
            reward: msg.value,
            employer: msg.sender,
            worker: address(0),
            isCompleted: false
        });

        emit TaskCreated(taskCount, description, msg.value, msg.sender);
    }

    function claimTask(uint256 taskId) public taskExists(taskId) notCompleted(taskId) {
        Task storage task = tasks[taskId];
        require(task.worker == address(0), "Task is already claimed.");

        task.worker = msg.sender;

        emit TaskClaimed(taskId, msg.sender);
    }

    function completeTask(uint256 taskId) public taskExists(taskId) onlyWorker(taskId) notCompleted(taskId) {
        Task storage task = tasks[taskId];

        task.isCompleted = true;

        emit TaskCompleted(taskId, msg.sender);
    }

    function claimReward(uint256 taskId) public taskExists(taskId) onlyWorker(taskId) {
        Task storage task = tasks[taskId];
        require(task.isCompleted, "Task must be completed to claim reward.");

        uint256 reward = task.reward;
        task.reward = 0;

        payable(task.worker).transfer(reward);

        emit RewardClaimed(taskId, task.worker, reward);
    }

    function getTaskDetails(uint256 taskId) public view taskExists(taskId) returns (string memory, uint256, address, address, bool) {
        Task memory task = tasks[taskId];
        return (task.description, task.reward, task.employer, task.worker, task.isCompleted);
    }
}
```
          
         

After pasting this code you have to compile the code from the left hand sidebar. click on the 'Solidity Compiler' then click on the 'Compile skillbasedtaskmarket.sol' button.

After the successful compilation of the code you have to deploy the program. For that you have again another option on the left sidebar that is 'Deploy & Run Transactions' and then you will see a deploy button; before clicking on it make sure that the file showing there is 'skillbasedtaskmarket.sol'. Then you will be able to see the file in the 'Deployed/Unpinned Contracts' click on that now all the public variable and functions are visible to you now execute and fetch the values according to you.


## Authors
Abhinesh kumar

## License
This project is licensed under the MIT License.
