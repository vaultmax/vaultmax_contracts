// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./StratX2.sol";

interface ILoanToken {
  function mint(address receiver, uint256 depositAmount)
      external
      returns (uint256);
}

contract StratX2_BZX is StratX2 {
    constructor(
        address[] memory _addresses,
        uint256 _pid,
        bool _isCAKEStaking,
        bool _isSameAssetDeposit,
        bool _isAutoComp,
        address[] memory _earnedToVMAXPath,
        address[] memory _earnedToToken0Path,
        address[] memory _earnedToToken1Path,
        address[] memory _token0ToEarnedPath,
        address[] memory _token1ToEarnedPath,
        uint256 _controllerFee,
        uint256 _buyBackRate,
        uint256 _entranceFeeFactor,
        uint256 _withdrawFeeFactor
    ) public {
        wbnbAddress = _addresses[0];
        govAddress = _addresses[1];
        VMAXFarmAddress = _addresses[2];
        VMAXAddress = _addresses[3];

        wantAddress = _addresses[4];
        token0Address = _addresses[5];
        token1Address = _addresses[6];
        earnedAddress = _addresses[7];

        farmContractAddress = _addresses[8];
        pid = _pid;
        isCAKEStaking = _isCAKEStaking;
        isSameAssetDeposit = _isSameAssetDeposit;
        isAutoComp = _isAutoComp;

        uniRouterAddress = _addresses[9];
        buybackRouterAddress = _addresses[10];
        earnedToVMAXPath = _earnedToVMAXPath;
        earnedToToken0Path = _earnedToToken0Path;
        earnedToToken1Path = _earnedToToken1Path;
        token0ToEarnedPath = _token0ToEarnedPath;
        token1ToEarnedPath = _token1ToEarnedPath;

        controllerFee = _controllerFee;
        rewardsAddress = _addresses[11];
        buyBackRate = _buyBackRate;
        buyBackAddress = _addresses[12];
        entranceFeeFactor = _entranceFeeFactor;
        withdrawFeeFactor = _withdrawFeeFactor;

        transferOwnership(VMAXFarmAddress);
    }


    function earn() public override nonReentrant whenNotPaused {
        require(isAutoComp, "!isAutoComp");
        if (onlyGov) {
            require(msg.sender == govAddress, "!gov");
        }
        // Harvest farm tokens
        _unfarm(0);
        if (earnedAddress == wbnbAddress) {
            _wrapBNB();
        }
        // Converts farm tokens into want tokens
        uint256 earnedAmt = IERC20(earnedAddress).balanceOf(address(this));
        earnedAmt = distributeFees(earnedAmt);
        earnedAmt = buyBack(earnedAmt);
        IERC20(earnedAddress).safeApprove(uniRouterAddress, 0);
        IERC20(earnedAddress).safeIncreaseAllowance(
            uniRouterAddress,	
            earnedAmt
        );
        _safeSwap(
            uniRouterAddress,
            earnedAmt,
            slippageFactor,
            earnedToToken0Path,
            address(this),
            block.timestamp.add(600)
        );
        // Get want tokens, ie. get iToken
        uint256 token0Amt = IERC20(token0Address).balanceOf(address(this));
        IERC20(token0Address).safeApprove(wantAddress, 0);
        IERC20(token0Address).safeIncreaseAllowance(wantAddress, token0Amt);
        ILoanToken(wantAddress).mint(address(this), token0Amt);
        lastEarnBlock = block.number;
        _farm();
    }

}
