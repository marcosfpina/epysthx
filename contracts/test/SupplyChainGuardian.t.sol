// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {BuildAttestation} from "../src/supplychain/BuildAttestation.sol";
import {SupplyChainGuardian} from "../src/supplychain/SupplyChainGuardian.sol";

contract SupplyChainGuardianTest is Test {
    SupplyChainGuardian private guardian;
    address private builder = makeAddr("builder");

    bytes32 private constant PACKAGE_HASH = keccak256("neotron-0.1.0");
    bytes32 private constant SBOM_HASH = keccak256("cyclonedx-sbom");
    bytes32 private constant SOURCE_COMMIT = keccak256("source-commit");
    bytes32 private constant FLAKE_INPUT_HASH = keccak256("flake-lock");

    function setUp() public {
        guardian = new SupplyChainGuardian();
    }

    function test_AttestPackageCompletesFullPipeline() public {
        vm.prank(builder);
        bytes32 result = _attestPackage();

        assertEq(result, PACKAGE_HASH);
        assertEq(guardian.getTotalAttestations(), 1);

        SupplyChainGuardian.PackageAttestation memory attestation =
            guardian.getAttestation(PACKAGE_HASH);
        assertEq(attestation.attestedBy, builder);
        assertTrue(attestation.complete);

        (bool sbomExists, bool buildVerified, bool licenseValid, bool auditLogged) =
            guardian.verifySupplyChain(PACKAGE_HASH);
        assertTrue(sbomExists);
        assertTrue(buildVerified);
        assertTrue(licenseValid);
        assertTrue(auditLogged);

        assertEq(guardian.sbomRegistry().getTotalSBOMs(), 1);
        assertEq(guardian.buildAttestation().getTotalBuilds(), 1);
        assertEq(guardian.licenseRegistry().getTotalLicenses(), 1);
        assertEq(guardian.auditLogger().totalLogs(), 1);
    }

    function test_GuardianIsRegisteredBuildService() public view {
        BuildAttestation.Builder memory registered =
            guardian.buildAttestation().getBuilder(address(guardian));

        assertEq(registered.builderAddress, address(guardian));
        assertEq(registered.name, "SupplyChainGuardian");
        assertTrue(registered.active);
    }

    function test_AttestPackageRejectsDuplicatePackage() public {
        vm.prank(builder);
        _attestPackage();

        vm.prank(builder);
        vm.expectRevert(
            abi.encodeWithSelector(
                SupplyChainGuardian.AttestationAlreadyComplete.selector, PACKAGE_HASH
            )
        );
        _attestPackage();
    }

    function _attestPackage() private returns (bytes32) {
        return guardian.attestPackage(
            PACKAGE_HASH,
            "neotron",
            "0.1.0",
            "Apache-2.0",
            SBOM_HASH,
            "ipfs://sbom",
            BuildAttestation.SLSALevel.Level3,
            SOURCE_COMMIT,
            "https://github.com/kernelcore/neotron",
            FLAKE_INPUT_HASH,
            "ipfs://provenance",
            0,
            false,
            "LGPD",
            46,
            "ipfs://audit"
        );
    }
}
