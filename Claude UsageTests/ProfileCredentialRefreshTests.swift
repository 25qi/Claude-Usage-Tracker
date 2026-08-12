//
//  ProfileCredentialRefreshTests.swift
//  Claude UsageTests
//
//  Regression coverage for the expired-token deadlock: an expired access token
//  that still carries a refresh token must remain "refreshable" so the refresh
//  path stays reachable.
//

import XCTest
@testable import Claude_Usage

final class ProfileCredentialRefreshTests: XCTestCase {

    /// Builds a Claude Code credentials payload with the given expiry offset.
    private func credentialsJSON(
        expiresInSeconds: TimeInterval,
        includeRefreshToken: Bool = true
    ) -> String {
        let expiresAtMillis = Int((Date().addingTimeInterval(expiresInSeconds)).timeIntervalSince1970 * 1000)
        let refreshEntry = includeRefreshToken ? "\"refreshToken\": \"rt-test-token\"," : ""
        return """
        {
          "claudeAiOauth": {
            "accessToken": "at-test-token",
            \(refreshEntry)
            "expiresAt": \(expiresAtMillis)
          }
        }
        """
    }

    // 過期 + 有 refresh token:不能算「當下可用」,但必須算「可續期」。
    // 這正是死結的核心,前置檢查若只看 hasValidCLIOAuth 就會永遠擋掉更新。
    func testExpiredTokenWithRefreshTokenIsStillRefreshable() {
        let profile = Profile(
            name: "Expired",
            cliCredentialsJSON: credentialsJSON(expiresInSeconds: -3600)
        )

        XCTAssertFalse(profile.hasValidCLIOAuth, "expired token must not count as valid")
        XCTAssertTrue(profile.hasRefreshableCLIOAuth, "expired token with a refresh token must stay refreshable")
    }

    func testValidTokenIsBothValidAndRefreshable() {
        let profile = Profile(
            name: "Valid",
            cliCredentialsJSON: credentialsJSON(expiresInSeconds: 3600)
        )

        XCTAssertTrue(profile.hasValidCLIOAuth)
        XCTAssertTrue(profile.hasRefreshableCLIOAuth)
    }

    func testExpiredTokenWithoutRefreshTokenIsNotRefreshable() {
        let profile = Profile(
            name: "Dead",
            cliCredentialsJSON: credentialsJSON(expiresInSeconds: -3600, includeRefreshToken: false)
        )

        XCTAssertFalse(profile.hasValidCLIOAuth)
        XCTAssertFalse(profile.hasRefreshableCLIOAuth, "no refresh token means nothing to renew with")
    }

    func testProfileWithoutCLICredentialsIsNotRefreshable() {
        let profile = Profile(name: "Empty")

        XCTAssertFalse(profile.hasValidCLIOAuth)
        XCTAssertFalse(profile.hasRefreshableCLIOAuth)
    }
}
