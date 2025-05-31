# PatientConsent

A blockchain-based patient consent management system built on the Stacks blockchain.

## Overview

PatientConsent provides a secure and transparent way to manage patient consent for medical procedures. The system ensures that consent is properly documented, verifiable, and can be revoked by patients at any time.

## Features

- Secure recording of patient consent for medical procedures
- Cryptographic verification of consent documents
- Time-limited consent with automatic expiration
- Patient ability to revoke consent at any time
- Complete audit trail of all consent activities

## Smart Contract Functions

- `register-consent`: Record a new patient consent for a procedure
- `revoke-consent`: Allow a patient to withdraw their consent
- `verify-consent`: Check if a consent is valid and not expired
- `get-consent-details`: Retrieve complete information about a consent record
- `get-patient-consents`: View all consents for a specific patient
- `has-consent-for-procedure`: Check if a patient has valid consent for a specific procedure

## Getting Started

1. Clone this repository
2. Install Clarinet: `npm install -g @stacks/clarinet`
3. Run tests: `clarinet test`

## Security Considerations

- The contract stores only hashes of consent documents, not the actual data
- Consent has automatic expiration to ensure timely renewal
- Patients can revoke consent at any time
- Complete audit trail of all consent activities
