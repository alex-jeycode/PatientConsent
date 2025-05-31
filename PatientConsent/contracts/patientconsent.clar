;; PatientConsent - Blockchain-based patient consent management
;; Version: 1.0.0

;; Data structures
(define-map consent-records
  { consent-id: (string-ascii 64) }
  { 
    patient-id: (string-ascii 64),
    procedure-id: (string-ascii 64),
    doctor-id: (string-ascii 64),
    consent-hash: (string-ascii 128),
    timestamp: uint,
    expiration: uint,
    revoked: bool,
    revocation-time: (optional uint)
  })

(define-map patient-consents
  { patient-id: (string-ascii 64) }
  { consent-ids: (list 20 (string-ascii 64)) })

(define-data-var admin principal tx-sender)

;; Register a new consent record
(define-public (register-consent
  (consent-id (string-ascii 64))
  (patient-id (string-ascii 64))
  (procedure-id (string-ascii 64))
  (doctor-id (string-ascii 64))
  (consent-hash (string-ascii 128))
  (expiration uint))
  (let ((patient-consent-list (default-to { consent-ids: (list) } 
                              (map-get? patient-consents { patient-id: patient-id }))))
    (begin
      (asserts! (not (is-some (map-get? consent-records { consent-id: consent-id }))) (err u409))
      (map-set consent-records
        { consent-id: consent-id }
        { 
          patient-id: patient-id,
          procedure-id: procedure-id,
          doctor-id: doctor-id,
          consent-hash: consent-hash,
          timestamp: stacks-block-height,
          expiration: expiration,
          revoked: false,
          revocation-time: none
        })
      (map-set patient-consents
        { patient-id: patient-id }
        { consent-ids: (unwrap-panic (as-max-len? 
                                      (append (get consent-ids patient-consent-list) consent-id)
                                      u20)) })
      (ok true))))

;; Revoke a consent
(define-public (revoke-consent (consent-id (string-ascii 64)))
  (let ((consent (map-get? consent-records { consent-id: consent-id })))
    (begin
      (asserts! (is-some consent) (err u404))
      (asserts! (not (get revoked (unwrap-panic consent))) (err u400))
      (ok (map-set consent-records
        { consent-id: consent-id }
        (merge (unwrap-panic consent) 
              { revoked: true, revocation-time: (some stacks-block-height) }))))))

;; Verify if a consent is valid
(define-read-only (verify-consent (consent-id (string-ascii 64)))
  (let ((consent (map-get? consent-records { consent-id: consent-id })))
    (if (is-some consent)
      (let ((consent-data (unwrap-panic consent)))
        (if (and 
              (not (get revoked consent-data)) 
              (< stacks-block-height (get expiration consent-data)))
          (ok true)
          (ok false)))
      (err u404))))

;; Get consent details
(define-read-only (get-consent-details (consent-id (string-ascii 64)))
  (map-get? consent-records { consent-id: consent-id }))

;; Get all consents for a patient
(define-read-only (get-patient-consents (patient-id (string-ascii 64)))
  (map-get? patient-consents { patient-id: patient-id }))

;; Helper function for checking procedure consent
(define-private (check-procedure-consent 
  (acc { found: bool, target-procedure: (string-ascii 64) }) 
  (consent-id (string-ascii 64)))
  (if (get found acc)
    acc
    (let ((consent (map-get? consent-records { consent-id: consent-id })))
      (if (and (is-some consent) 
               (is-eq (get procedure-id (unwrap-panic consent)) (get target-procedure acc))
               (not (get revoked (unwrap-panic consent)))
               (< stacks-block-height (get expiration (unwrap-panic consent))))
        { found: true, target-procedure: (get target-procedure acc) }
        acc))))
