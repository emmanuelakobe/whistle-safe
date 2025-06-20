# 🕵️‍♂️ WhistleSafe — Anonymous Whistleblowing Smart Contract

**WhistleSafe** is a decentralized, privacy-preserving smart contract system for secure and anonymous whistleblowing. It allows users to submit encrypted reports or evidence on-chain, with access control for designated reviewers. WhistleSafe enables trustless reporting, transparent auditing, and role-based case handling without exposing whistleblower identities.

---

## 🔐 Key Features

- 🧾 **Anonymous Report Submission**
  - Whistleblowers submit encrypted reports via public key encryption.
  - No link to `msg.sender` or wallet address is stored on-chain.

- 🔑 **Encrypted Metadata Storage**
  - Encrypted IPFS/Arweave hashes allow off-chain evidence management with on-chain verification.

- 👮 **Role-Based Reviewer System**
  - Only reviewers with `REVIEWER_ROLE` can access and resolve reports.

- 📡 **Event-Only Disclosure**
  - Critical data is emitted as events (not stored on-chain) for off-chain analysis and privacy preservation.

- 🔁 **Escalation and Resolution**
  - Reviewers can mark reports as resolved, escalate, or flag for DAO governance actions.

---

## 🧱 Contract Architecture

### Report Structure (Minimal Metadata)

```solidity
struct Report {
  uint256 reportId;
  string encryptedDataURI; // IPFS/Arweave hash of encrypted data
  bool resolved;
}
Public Functions
function submitReport(string calldata encryptedDataURI) external
function resolveReport(uint256 reportId) external onlyReviewer
function escalateReport(uint256 reportId) external onlyReviewer
🛠️ Tech Stack
Solidity ^0.8.x

OpenZeppelin (AccessControl)

IPFS / Arweave for decentralized file storage

Hardhat for local development and testing

Ethers.js for frontend or server interaction

📦 Installation
git clone https://github.com/yourusername/whistle-safe.git
cd whistle-safe
npm install
🚀 Deployment
Use Hardhat or other EVM-compatible tools:

npx hardhat compile
npx hardhat run scripts/deploy.js --network <network-name>
Make sure to update your .env with proper network and key settings.

🔍 Example Usage
Submitting a Report (Frontend / dApp)
js
await whistleSafe.submitReport(
  "ipfs://Qm...EncryptedHash"  // Submitted by user anonymously
);
Resolving a Report (Reviewer Only)
js
await whistleSafe.resolveReport(0);  // Reviewer marks report #0 as resolved
✅ Tests
bash
npx hardhat test
Test Coverage:

Anonymous submission validation

Reviewer role enforcement

Resolution and escalation workflows

Event emission accuracy

📁 Project Structure
bash
contracts/
├── WhistleSafe.sol         # Core smart contract

scripts/
├── deploy.js               # Deployment script

test/
├── whistleSafe.test.js     # Unit tests

utils/
├── encrypt.js              # Optional: frontend encryption helper
🔐 Security Considerations
❌ No msg.sender tracking for whistleblower privacy

✅ Role-based access for reviewer functions

✅ Encrypted data URIs reduce risk of on-chain surveillance

🕵️‍♂️ Recommend frontend-side encryption using recipient’s public key

🔍 Codebase ready for formal security audit

🔄 Future Enhancements
 Zero-Knowledge Proof support (e.g., ZK-SNARK for verifiable yet private disclosures)

 Off-chain review queue with DAO-controlled escalation

 Expiry system for unresolved reports

 Verifiable credentials or DIDs for trusted anonymous identities
