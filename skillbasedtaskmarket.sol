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
        assert(task.isCompleted == true); 

        emit TaskCompleted(taskId, msg.sender);
    }

    function claimReward(uint256 taskId) public taskExists(taskId) onlyWorker(taskId) {
        Task storage task = tasks[taskId];
        require(task.isCompleted, "Task must be completed to claim reward.");

        uint256 reward = task.reward;
        task.reward = 0;

        (bool success, ) = task.worker.call{value: reward}("");
        if (!success) {
            revert("Transfer failed.");
        }

        emit RewardClaimed(taskId, task.worker, reward);
    }

    function getTaskDetails(uint256 taskId) public view taskExists(taskId) returns (string memory, uint256, address, address, bool) {
        Task memory task = tasks[taskId];
        return (task.description, task.reward, task.employer, task.worker, task.isCompleted);
    }
}
