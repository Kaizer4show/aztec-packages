// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Aztec Labs.
pragma solidity >=0.8.18;

import {Test} from "forge-std/Test.sol";

import {Hash} from "@aztec/core/libraries/Hash.sol";
import {Constants} from "@aztec/core/libraries/Constants.sol";
import {DataStructures} from "@aztec/core/libraries/DataStructures.sol";
import {DecoderHelper} from "./DecoderHelper.sol";
import {Registry} from "@aztec/core/messagebridge/Registry.sol";
import {Inbox} from "@aztec/core/messagebridge/Inbox.sol";
import {Outbox} from "@aztec/core/messagebridge/Outbox.sol";
import {Rollup} from "@aztec/core/Rollup.sol";

/**
 * Blocks are generated using the `integration_l1_publisher.test.ts` tests.
 * Main use of these test is shorter cycles when updating the decoder contract.
 */
contract DecoderTest is Test {
  DecoderHelper internal helper;
  Registry internal registry;
  Inbox internal inbox;
  Outbox internal outbox;
  Rollup internal rollup;

  bytes internal block_empty_1 =
    hex"000000010668938c4a4167faa2b5031e427d74d6e38638d2eef68834b70480c5a93f8e15000000002d39729fd006096882acfbd350c91fd61883578b4fe35b63cdce3c1993a497ea000000082f8dc86ba80d8fcf491fb7a255f4163e4f9601d022ba0be35f13297531073fd80000000019c36f7bc2e4116d082865cc0b4ac8e16e9efa00ace9fb2222dd1dfd719cb671000000012b36b22912aa963f143c490227bd21e7a44338026b2f6a389cb98e82167c3718000000012b72136df9bc7dc9cbfe6b84ec743e8e1d73dd93aecfa79f18afb86be977d3eb0668938c4a4167faa2b5031e427d74d6e38638d2eef68834b70480c5a93f8e150000000019c36f7bc2e4116d082865cc0b4ac8e16e9efa00ace9fb2222dd1dfd719cb671000000010668938c4a4167faa2b5031e427d74d6e38638d2eef68834b70480c5a93f8e15000000102d39729fd006096882acfbd350c91fd61883578b4fe35b63cdce3c1993a497ea000000182f8dc86ba80d8fcf491fb7a255f4163e4f9601d022ba0be35f13297531073fd800000004238b20b7bc1d5190f8e928eb2aa2094412588f9cad6c7862f69c09a9b246d6ed0000000225d4ca531bca7d097a93bc47d7aa2c4dbcc8d0d5ecf4138849104e363eb52c03000000022b72136df9bc7dc9cbfe6b84ec743e8e1d73dd93aecfa79f18afb86be977d3eb0668938c4a4167faa2b5031e427d74d6e38638d2eef68834b70480c5a93f8e1500000010238b20b7bc1d5190f8e928eb2aa2094412588f9cad6c7862f69c09a9b246d6ed000000020000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

  bytes internal block_mixed_1 =
    hex"000000010668938c4a4167faa2b5031e427d74d6e38638d2eef68834b70480c5a93f8e15000000002d39729fd006096882acfbd350c91fd61883578b4fe35b63cdce3c1993a497ea000000082f8dc86ba80d8fcf491fb7a255f4163e4f9601d022ba0be35f13297531073fd80000000019c36f7bc2e4116d082865cc0b4ac8e16e9efa00ace9fb2222dd1dfd719cb671000000012b36b22912aa963f143c490227bd21e7a44338026b2f6a389cb98e82167c3718000000012b72136df9bc7dc9cbfe6b84ec743e8e1d73dd93aecfa79f18afb86be977d3eb0668938c4a4167faa2b5031e427d74d6e38638d2eef68834b70480c5a93f8e150000000019c36f7bc2e4116d082865cc0b4ac8e16e9efa00ace9fb2222dd1dfd719cb671000000010813349a787d3f13ec3492de8b6a5c06ba871cb7d2533b8859f3c40693384501000000102e18315fa9fc796d3a94dfe61517725dec4e9d0811ce7e8ee3518cdbcf03549d00000018279f38b90665ef7dae8a59f015029274d7837545f62f1f00ab64ffb714d043e90000000412e58befb4676abe3a279ec129e4d48b53eb1b1724a6c01274b39f6122dfc0bf00000002128683784c66165b4b7acf1502ee0f2ed6e5e614f9992375e5f98b1566f2d20a000000022d9b8d2353587ca56bdf967b4bb8847af3671bd6901e9e28f82c240c6e33129a1b3ab03f9b9fb0f8a31ed10a930e476c7b8bfcc9018d6dfbe20eb15838a701e9000000103036ed03e75f4893197d647af9e8f5dae3659ac9003c6b144dbb86b71820307400000002000000100000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000012100000000000000000000000000000000000000000000000000000000000001220000000000000000000000000000000000000000000000000000000000000123000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001410000000000000000000000000000000000000000000000000000000000000142000000000000000000000000000000000000000000000000000000000000014300000000000000000000000000000000000000000000000000000000000001600000000000000000000000000000000000000000000000000000000000000161000000000000000000000000000000000000000000000000000000000000016200000000000000000000000000000000000000000000000000000000000001630000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000018100000000000000000000000000000000000000000000000000000000000001820000000000000000000000000000000000000000000000000000000000000183000000100000000000000000000000000000000000000000000000000000000000000220000000000000000000000000000000000000000000000000000000000000022100000000000000000000000000000000000000000000000000000000000002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002410000000000000000000000000000000000000000000000000000000000000242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000000000000000000000000000261000000000000000000000000000000000000000000000000000000000000026200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000280000000000000000000000000000000000000000000000000000000000000028100000000000000000000000000000000000000000000000000000000000002820000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000520000000000000000000000000000000000000000000000000000000000000052a0000000000000000000000000000000000000000000000000000000000000521000000000000000000000000000000000000000000000000000000000000052b0000000000000000000000000000000000000000000000000000000000000522000000000000000000000000000000000000000000000000000000000000052c0000000000000000000000000000000000000000000000000000000000000523000000000000000000000000000000000000000000000000000000000000052d0000000000000000000000000000000000000000000000000000000000000540000000000000000000000000000000000000000000000000000000000000054a0000000000000000000000000000000000000000000000000000000000000541000000000000000000000000000000000000000000000000000000000000054b0000000000000000000000000000000000000000000000000000000000000542000000000000000000000000000000000000000000000000000000000000054c0000000000000000000000000000000000000000000000000000000000000543000000000000000000000000000000000000000000000000000000000000054d0000000000000000000000000000000000000000000000000000000000000560000000000000000000000000000000000000000000000000000000000000056a0000000000000000000000000000000000000000000000000000000000000561000000000000000000000000000000000000000000000000000000000000056b0000000000000000000000000000000000000000000000000000000000000562000000000000000000000000000000000000000000000000000000000000056c0000000000000000000000000000000000000000000000000000000000000563000000000000000000000000000000000000000000000000000000000000056d0000000000000000000000000000000000000000000000000000000000000580000000000000000000000000000000000000000000000000000000000000058a0000000000000000000000000000000000000000000000000000000000000581000000000000000000000000000000000000000000000000000000000000058b0000000000000000000000000000000000000000000000000000000000000582000000000000000000000000000000000000000000000000000000000000058c0000000000000000000000000000000000000000000000000000000000000583000000000000000000000000000000000000000000000000000000000000058d00000008000000000000000000000000000000000000000000000000000000000000032000000000000000000000000000000000000000000000000000000000000003210000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000034100000000000000000000000000000000000000000000000000000000000003600000000000000000000000000000000000000000000000000000000000000361000000000000000000000000000000000000000000000000000000000000038000000000000000000000000000000000000000000000000000000000000003810000000426fcb9639d15aabe6d792e23ab12fb9633046d4be6911a60d64471d7560d3f6809143b7d4943a3485115d37e7596938a16c91b6055f3837640d8c36b8303bb3c06fb5fb553496e5e0b48834087e036acf99d6d935dc2ebf43c82788cb5ed1c6a2f4bd77ac2bb5474d48c2856135d18168cd6f69f77143c60b3cc370319419dac0000000000000000000000000000000000000000000000000000000000001020212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000010404141414141414141414141414141414141414141000000000000000000000000000000000000000000000000000000000000106061616161616161616161616161616161616161610000000000000000000000000000000000000000000000000000000000001080818181818181818181818181818181818181818100000010151de48ca3efbae39f180fe00b8f472ec9f25be10b4f283a87c6d7839353703914c2ea9dedf77698d4afe23bc663263eed0bf9aa3a8b17d9b74812f185610f9e1570cc6641699e3ae87fa258d80a6d853f7b8ccb211dc244d017e2ca6530f8a12806c860af67e9cd50000378411b8c4c4db172ceb2daa862b259b689ccbdc1e005f140c7c95624c8006774279a01ec1ea88617999e4fe6997b6576c4e1c7395a22048b96b586596bd740d0402e15f5577f7ceb5496b65aafc6d89d7c3b34924b0c3f2d50d16279970d682cada30bfa6b29bc0bac0ee2389f6a0444853eccaa932b2a60561da46a58569d71044a84c639e7f88429826e5622581536eb906d9cdd25a2c0a76f7da6924e10751c755227d2535f4ad258b984e78f9f452a853c52300e212d8e2069e4254d81af07744bcbb81121a38f0e2dbed69a523d3fbf85b75c287ca6f33aadbac2e4f058e05924c140d7895a6ed167caf804b710d2ae3ba62b1b51297b3ea37637af6bd56cf33425d95cc5c96e9c2ee3077322fbec86a0c7f32c15d2a888c6cc122e99478c92470a1311635142d82ad7ae67410beeef4ae31f0902ba2fb964922a4610bb18901f7b923885c1d034da5769a48203ae6f0206a92855e2c01ddb3d6553386b5580d681b8230fa4062948668f834f23e0636eaff70aaa64519aafdf4b040bd2f9836e76b9dc13cfec8065dcdf2834d786e06260d1";

  function setUp() public virtual {
    helper = new DecoderHelper();

    registry = new Registry();
    inbox = new Inbox(address(registry));
    outbox = new Outbox(address(registry));
    rollup = new Rollup(registry);

    registry.upgrade(address(rollup), address(inbox), address(outbox));
  }

  function testEmptyBlock() public virtual {
    (bytes32 diffRoot, bytes32 l1ToL2MessagesHash) =
      helper.computeDiffRootAndMessagesHash(block_empty_1);
    assertEq(
      diffRoot,
      0xe861f905de96ae1d3fcec548d838e11aac2a74fccd23a7950689a46200f875ed,
      "Invalid diff root"
    );

    assertEq(
      l1ToL2MessagesHash,
      0x076a27c79e5ace2a3d47f9dd2e83e4ff6ea8872b3c2218f66c92b89b55f36560,
      "Invalid messages hash"
    );

    (
      uint256 l2BlockNumber,
      bytes32 startStateHash,
      bytes32 endStateHash,
      bytes32 publicInputsHash,
      bytes32[] memory l2ToL1Msgs,
      bytes32[] memory l1ToL2Msgs
    ) = helper.decode(block_empty_1);

    assertEq(l2BlockNumber, 1, "Invalid block number");
    assertEq(
      startStateHash,
      0x2d5d49acd86a4ce5d71f632bd8c39d61d12c7be4ad4ab1f17e134e55aa4e29c2,
      "Invalid start state hash"
    );
    assertEq(
      endStateHash,
      0x3dff2c815f7e5f5b8b3a2397347cc928001c73e5442d6dad5af61c3329b4fc8c,
      "Invalid end state hash"
    );
    assertEq(
      publicInputsHash,
      0x2c6390588e4d61282f591e92758e46770196d0fe7fe873285a52a540455eb001,
      "Invalid public input hash"
    );

    for (uint256 i = 0; i < l2ToL1Msgs.length; i++) {
      assertEq(l2ToL1Msgs[i], bytes32(0), "Invalid l2ToL1Msgs");
    }
    for (uint256 i = 0; i < l1ToL2Msgs.length; i++) {
      assertEq(l1ToL2Msgs[i], bytes32(0), "Invalid l1ToL2Msgs");
    }
  }

  function testMixBlock() public virtual {
    (bytes32 diffRoot, bytes32 l1ToL2MessagesHash) =
      helper.computeDiffRootAndMessagesHash(block_mixed_1);
    assertEq(
      diffRoot,
      0x913ff7bd9c1ffe306109801403605f1c49576584a552f7e0e1d820981908672b,
      "Invalid diff root"
    );

    assertEq(
      l1ToL2MessagesHash,
      0xb213c9c543fce2a66720d26a913fe0d018f72a47ccfe698baafcf4cced343cfd,
      "Invalid messages hash"
    );

    (
      uint256 l2BlockNumber,
      bytes32 startStateHash,
      bytes32 endStateHash,
      bytes32 publicInputsHash,
      bytes32[] memory l2ToL1Msgs,
      bytes32[] memory l1ToL2Msgs
    ) = helper.decode(block_mixed_1);

    assertEq(l2BlockNumber, 1, "Invalid block number");
    assertEq(
      startStateHash,
      0x2d5d49acd86a4ce5d71f632bd8c39d61d12c7be4ad4ab1f17e134e55aa4e29c2,
      "Invalid start state hash"
    );
    assertEq(
      endStateHash,
      0x9f70897506bb28ad25a1d360afa9f0a8c8f351dcc5ee47c2dd9ca1941773de27,
      "Invalid end state hash"
    );
    assertEq(
      publicInputsHash,
      0x1f4baa4771cd4da3d7d08cb131c763c1d56ba1fa579bc33b4a7aa7dc377159c1,
      "Invalid public input hash"
    );

    for (uint256 i = 0; i < l2ToL1Msgs.length; i++) {
      // recreate the value generated by `integration_l1_publisher.test.ts`.
      bytes32 expectedValue = bytes32(uint256(0x300 + 32 * (1 + i / 2) + i % 2));
      assertEq(l2ToL1Msgs[i], expectedValue, "Invalid l2ToL1Msgs");
    }
    bytes32[] memory expectedL1ToL2Msgs = _populateInbox();
    for (uint256 i = 0; i < l1ToL2Msgs.length; i++) {
      assertEq(l1ToL2Msgs[i], expectedL1ToL2Msgs[i], "Invalid l1ToL2Msgs");
    }
  }

  function testComputeKernelLogsHashNoLogs() public {
    bytes memory emptyKernelData = hex"00000000"; // 4 empty bytes indicating that length of kernel logs is 0

    (bytes32 logsHash, uint256 bytesAdvanced) = helper.computeKernelLogsHash(emptyKernelData);

    assertEq(bytesAdvanced, emptyKernelData.length, "Advanced by an incorrect number of bytes");
    assertEq(logsHash, bytes32(0), "Logs hash should be 0 when there are no logs");
  }

  function testComputeKernelLogs1Iteration() public {
    // || K_LOGS_LEN | I1_LOGS_LEN | I1_LOGS ||
    // K_LOGS_LEN = 4 + 8 = 12 (hex"0000000c")
    // I1_LOGS_LEN = 8 (hex"00000008")
    // I1_LOGS = 8 random bytes (hex"aafdc7aa93e78a70")
    bytes memory emptyKernelData = hex"0000000c00000008aafdc7aa93e78a70";
    (bytes32 logsHash, uint256 bytesAdvanced) = helper.computeKernelLogsHash(emptyKernelData);

    // Note: First 32 bytes are 0 because those correspond to the hash of previous iteration and there was no previous
    //       iteration.

    bytes32 referenceLogsHash = Hash.sha256ToField(
      hex"0000000000000000000000000000000000000000000000000000000000000000aafdc7aa93e78a70"
    );

    assertEq(bytesAdvanced, emptyKernelData.length, "Advanced by an incorrect number of bytes");
    assertEq(logsHash, referenceLogsHash, "Logs hash should be 0 when there are no logs");
  }

  function testComputeKernelLogs2Iterations() public {
    // || K_LOGS_LEN | I1_LOGS_LEN | I1_LOGS | I2_LOGS_LEN | I2_LOGS ||
    // K_LOGS_LEN = 4 + 8 + 4 + 20 = 36 (hex"00000024")
    // I1_LOGS_LEN = 8 (hex"00000008")
    // I1_LOGS = 8 random bytes (hex"aafdc7aa93e78a70")
    // I2_LOGS_LEN = 20 (hex"00000014")
    // I2_LOGS = 20 random bytes (hex"97aee30906a86173c86c6d3f108eefc36e7fb014")
    bytes memory emptyKernelData =
      hex"0000002400000008aafdc7aa93e78a700000001497aee30906a86173c86c6d3f108eefc36e7fb014";
    (bytes32 logsHash, uint256 bytesAdvanced) = helper.computeKernelLogsHash(emptyKernelData);

    bytes32 referenceLogsHashFromIteration1 = Hash.sha256ToField(
      hex"0000000000000000000000000000000000000000000000000000000000000000aafdc7aa93e78a70"
    );

    bytes32 referenceLogsHashFromIteration2 = Hash.sha256ToField(
      bytes.concat(referenceLogsHashFromIteration1, hex"97aee30906a86173c86c6d3f108eefc36e7fb014")
    );

    assertEq(bytesAdvanced, emptyKernelData.length, "Advanced by an incorrect number of bytes");
    assertEq(
      logsHash, referenceLogsHashFromIteration2, "Logs hash should be 0 when there are no logs"
    );
  }

  function _populateInbox() internal returns (bytes32[] memory) {
    address sender = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;
    bytes32 recipient = 0x1647b194c649f5dd01d7c832f89b0f496043c9150797923ea89e93d5ac619a93;
    bytes32[] memory messages = new bytes32[](16);
    for (uint256 i = 0; i < 16; i++) {
      bytes32 content = bytes32(uint256(0x401 + i));
      uint32 deadline = type(uint32).max;

      vm.prank(sender);
      bytes32 temp = inbox.sendL2Message(
        DataStructures.L2Actor({actor: recipient, version: 1}), deadline, content, bytes32(0)
      );
      messages[i] = temp;
    }
    return messages;
  }
}
