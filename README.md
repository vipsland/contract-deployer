
# Deploy and verify

```

> npx hardhat run  ./scripts/deploy.js --network goerli                                                          

> npx hardhat verify --network goerli --constructor-args arguments.js 0xd61DeD7c9492d5552014a930f8f1912DC9ac3A98 

0xb8537612A990Ce10Bb7BA822d676eff113595a70


```

# Switcher

```
//1. nonmp is open {4,5,6,7}
//2. we want generated lucky NONMP and fetch winners and distribute MP token . we open mintMPIsOpen = true , and call sendMPForNOrmalUsers

//000 = 0 //presale prt is not active.
//111 = 7 //open for everyone.
//
//        1 = airdrop
//      1 0 = internal team
//    1 0 0 = normal user
// e.g.
// 1 = airdrop
// 2 = internal team
// 3 = air + int
// 4 = norm usr   // when them all sold
// 5 = norm + air
// 6 = norm + int
// 7 = everybody
// internal team + normal = binary 1 1 0 = 4 + 2 = 6
// airdrop + internal team = binary 1 1 = 2 + 1 = 3
// normal user + airdrop = binary 1 0 1 = 4 + 1 = 5
// internal team + normal = binary 1 1 0 = 4 + 2 = 6
// binary 1 0 0 = dec 4 = normal user
// decimal 0 - 7


```


## Debug functions we use to test winner

```

    //manually mint and transfer start, :debug 0x868a7f505d0A60d4Ec302E5d892c6fB4125aff77 winner test
    function mintDebug(uint tokenID) public onlyOwner {
        _mint(msg.sender, tokenID, 1, "");
    }

    function safeTransferDebug(uint tokenID, address addr) public onlyOwner {
        require(exists(tokenID), "e2");
        safeTransferFrom(msg.sender, addr, tokenID, 1, "");
    }
    
```