// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import "../../src/ethereum/KassUtils.sol";
import "../../src/ethereum/ERC1155/KassERC1155.sol";
import "./KassTestBase.sol";

contract KassBridgeInstanceCreationTest is KassTestBase {
    KassERC1155 public _l1TokenInstance;

    function setUp() public override {
        super.setUp();

        // request L1 instance
        requestL1InstanceCreation(L2_TOKEN_ADDRESS, L2_TOKEN_URI);
    }

    function testL1TokenInstanceComputedAddress() public {
        // pre compute address
        address computedL1TokenAddress = _kassBridge.computeL1TokenAddress(L2_TOKEN_ADDRESS);

        // create L1 instance
        address l1TokenAddress = _kassBridge.createL1Instance(L2_TOKEN_ADDRESS, L2_TOKEN_URI);

        assertEq(computedL1TokenAddress, l1TokenAddress);
    }

    function testL1TokenInstanceUri() public {
        // create L1 instance
        KassERC1155 l1TokenInstance = KassERC1155(_kassBridge.createL1Instance(L2_TOKEN_ADDRESS, L2_TOKEN_URI));

        assertEq(l1TokenInstance.uri(0), KassUtils.concat(L2_TOKEN_URI));
    }

    function testCannotCreateL1TokenInstanceWithDifferentL2TokenAddressFromL2Request() public {
        vm.expectRevert();
        _kassBridge.createL1Instance(L2_TOKEN_ADDRESS - 1, L2_TOKEN_URI);
    }

    function testCannotCreateL1TokenInstanceWithDifferentUriFromL2Request() public {
        string[] memory uri = new string[](L2_TOKEN_URI.length);

        // reverse `L2_TOKEN_URI`
        for (uint8 i = 0; i < uri.length; ++i) {
            uri[i] = L2_TOKEN_URI[uri.length - i - 1];
        }

        vm.expectRevert();
        _kassBridge.createL1Instance(L2_TOKEN_ADDRESS, uri);
    }
}
