# S3
## S3 Controls
|Validating Policy|Ref to standards|Status|
|----| ----| ----|
|s3-bucket-level-public-access-prohibited| NIST 800-53r5 AC-3(7) AC-3 AC-4(21) AC-4 AC-6 AC-21 SC-7(3) SC-7(4) SC-7(9) SC-7(11) SC-7(20) SC-7(21) SC-7| Complete |
|s3-bucket-logging-enabled.yaml| NIST 800-53r5 AC-2(4) AC-4(26) AC-6(9) AU-2 AU-3 AU-6(3) AU-6(4) AU-10 AU-12 CA-7 IA-3(3) IR-4(12) SC-7(9) SI-3(8) SI-4(20) SI-7(8)| Complete |
|s3-bucket-public-read-prohibited|| N/A covered by s3-bucket-level-public-access-prohibited|
|s3-bucket-public-write-prohibited| |N/A covered by s3-bucket-level-public-access-prohibited|
|s3-bucket-replication-enabled| AU-9(2) CP-10 CP-6 CP-6(1) CP-6(2) CP-9 SC-36(2) SC-5(2) SI-13(5)| Complete |
|s3-bucket-server-side-encryption-enabled| AU-9 CA-9(1) CM-3(6) SC-13 SC-28 SC-28(1) SC-7(10) SI-7(6)| Complete|
|s3-bucket-ssl-requests-only| AC-17(2) AC-4 IA-5(1) SC-13 SC-23 SC-7(4) SC-8 SC-8(1) SC-8(2) SI-7(6)| Complete |
|s3-bucket-versioning-enabled| AU-9(2) CP-10 CP-6 CP-6(1) CP-6(2) CP-9 SC-34(2) SC-5(2) SI-13(5)| Complete |
|s3-default-encryption-kms| AU-9 CA-9(1) CM-3(6) SC-13 SC-28(1) SC-7(10)| Complete |
|s3-event-notifications-enabled| CA-7 SI-3(8) SI-4 SI-4(4)| Complete |
|s3-version-lifecycle-policy-check| AU-9(2) CP-6(2) CP-9 CP-10 SC-5(2) SI-13(5)| Complete |



