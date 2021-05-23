# VaultMax SmartContracts

## Deployed Contracts

- VMAX: 0x00000000000000000000000000000
- VaultMaxLocker: 0x00000000000000000000000000000
- VMAXFarm: 0x00000000000000000000000000000
- VMAXFarmTimelock 0x00000000000000000000000000000




To guarantee high security for users we only use audited and battle-proof contracts. Only minor adjustements have been made. For full transparency, all contract sources and adjustements are documented below.

## Sources
### autofarm.network
StratX2.sol StratX2_BAKE.sol StratX2_BZX.sol StratX2_MDEX.sol StratX2_PCS.sol StratX_VMAX.sol VMAXFarm.sol VMAXFarmTimeLock.sol VMAXFarm_CrossChain.sol VMAXTimelock.sol
### pantherswap.com
VMAX.sol
VaultMaxLocker.sol



# Minor Adjustements

## VMAX Token Contract

VMAX.sol forked from https://github.com/pantherswap/panther-farm

increased ```minAmountToLiquify``` since we have a higher total supply


## Farm Contract

VMAXFarm.sol forked from https://github.com/autofarmnetwork/AutofarmV2_CrossChain


Tokenomics of VMAX (transfer tax) are taken into account when depositing in our vault (User -> Farm -> Vault)
```
//deduct transfer tax so VMAXFarm transfers the correct amount from farm to vault
if (address(pool.want) == address(VMAX)) {
  uint256 transferTax = _wantAmt.mul(IVMAX(VMAX).transferTaxRate()).div(10000);
  _wantAmt = _wantAmt.sub(transferTax);
  }
```

## VMAX Vault Contract

StratX_VMAX.sol forked from https://bscscan.com/address/0x65168C89a16FBEd4e2e418D5245FF626Bd66874b#code


Tokenomics of VMAX (transfer tax) are taken into account to return the correct share amount to VMAXFarm

```
//substract VMAX tax to record correct shares	
	          uint256 transferTax = _wantAmt.mul(IVMAX(VMAXAddress).transferTaxRate()).div(10000);	
	          _wantAmt = _wantAmt.sub(transferTax);
```


## Vault Contract

StratX2.sol forked from https://github.com/autofarmnetwork/AutofarmV2_CrossChain/blob/master/StratX2.sol


Added a second router ```address public buybackRouterAddress;``` so we can compound on DEX-X and buyback VMAX on DEX-Y

	
	        if (uniRouterAddress != buybackRouterAddress) {
	          IERC20(earnedAddress).safeIncreaseAllowance(
	              buybackRouterAddress,
	              buyBackAmt
	          );
	
	          _safeSwap(
	              buybackRouterAddress,
	              buyBackAmt,
	              slippageFactor,
	              earnedToVMAXPath,
	              buyBackAddress,
	              block.timestamp.add(600)
	          );
            
            

   
   
   
