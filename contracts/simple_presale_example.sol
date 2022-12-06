// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 public immutable finalTotalSupply = 10000 * 10**decimals();
    uint256 public immutable presaleMaxSupply = 1000 * 10**decimals();

    uint256 public presaleCounter = 0;
    uint256 public presaleCost1 = 0.05 ether; //cost1 for 1 * 10 ** decimals()
    uint256 public presaleCost2 = 0.1 ether; //cost2 for 1 * 10 ** decimals()

    uint8 public stage = 0; //0 - nothing, 1 - first presale round, 2 - second presale round, 3 - token launched

    constructor() ERC20("MyToken", "MTK") {}

    function buyOnPresale() public payable {
        require(
            stage == 1 || stage == 2,
            "Presale has not started yet or has already ended!"
        );

        uint256 cost = presaleCost1;
        if (stage == 2) cost = presaleCost2;

        uint256 amount = (msg.value * 10**decimals()) / cost;
        require(amount > 1, "Too little value!");

        uint256 newSupply = totalSupply() + amount;
        require(newSupply <= finalTotalSupply, "Final supply reached!");

        presaleCounter += amount;
        require(
            presaleCounter <= presaleMaxSupply,
            "Final presale supply reached!"
        );

        _mint(msg.sender, amount);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        uint256 newSupply = totalSupply() + amount * 10**decimals();
        require(newSupply <= finalTotalSupply, "Final supply reached!");
        _mint(to, amount * 10**decimals());
    }

    function setStage(uint8 _stg) public onlyOwner {
        stage = _stg;
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

}
