;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WHISTLE-SAFE - Anonymous Whistleblower Smart Contract
;; Description: Submit hashed reports, DAO verifies, bounty rewarded
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var contract-owner principal tx-sender)

(define-map reports
  uint
  {
    reporter-hash: (buff 32),
    report-hash: (buff 32),
    status: uint,       ;; 0 = pending, 1 = approved, 2 = rejected, 3 = claimed
    bounty: uint
  }
)

(define-data-var next-report-id uint u1)

;; Error codes
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_NOT_FOUND u101)
(define-constant ERR_NOT_APPROVED u102)
(define-constant ERR_HASH_MISMATCH u103)
(define-constant ERR_ALREADY_CLAIMED u104)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PUBLIC FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 1. Submit an anonymous report
(define-public (submit-report (reporter-hash (buff 32)) (report-hash (buff 32)) (bounty uint))
  (let ((id (var-get next-report-id)))
    (begin
      (try! (stx-transfer? bounty tx-sender (as-contract tx-sender)))
      (map-set reports id {
        reporter-hash: reporter-hash,
        report-hash: report-hash,
        status: u0,
        bounty: bounty
      })
      (var-set next-report-id (+ id u1))
      (ok id)
    )
  )
)

;; 2. DAO or owner approves/rejects a report
(define-public (verify-report (report-id uint) (approve bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
    (match (map-get? reports report-id)
      report-data (begin 
            (map-set reports report-id {
              reporter-hash: (get reporter-hash report-data),
              report-hash: (get report-hash report-data),
              status: (if approve u1 u2),
              bounty: (get bounty report-data)
            })
            (ok true))
      (err ERR_NOT_FOUND)
    )
  )
)

;; 3. Claim bounty if report is approved and hash matches
(define-public (claim-bounty (report-id uint) (proof-hash (buff 32)))
  (match (map-get? reports report-id)
    report-data (begin
        (asserts! (is-eq (get status report-data) u1) (err ERR_NOT_APPROVED))
        (asserts! (is-eq (get reporter-hash report-data) proof-hash) (err ERR_HASH_MISMATCH))
        (asserts! (> (get bounty report-data) u0) (err ERR_ALREADY_CLAIMED))
        (try! (stx-transfer? (get bounty report-data) (as-contract tx-sender) tx-sender))
        (map-set reports report-id {
          reporter-hash: (get reporter-hash report-data),
          report-hash: (get report-hash report-data),
          status: u3,
          bounty: u0
        })
        (ok true)
      )
    (err ERR_NOT_FOUND)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READ-ONLY FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-report (id uint))
  (map-get? reports id)
)

(define-read-only (get-next-id)
  (ok (var-get next-report-id))
)
