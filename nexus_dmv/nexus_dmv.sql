-- =============================================
--  Nexus DMV - Database Setup
-- Author: Ken Mondragon
-- =============================================

-- This script uses the existing esx_license system
-- No additional tables are needed

-- However, if you need to set up esx_license from scratch,
-- here is the basic structure:

-- CREATE TABLE IF NOT EXISTS `user_licenses` (
--   `id` int(11) NOT NULL AUTO_INCREMENT,
--   `type` varchar(60) NOT NULL,
--   `owner` varchar(60) NOT NULL,
--   PRIMARY KEY (`id`),
--   KEY `owner` (`owner`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- License types used by this resource:
-- 'dmv'        - Theory test license (required for driving tests)
-- 'drive'      - Car driving license
-- 'drive_bike' - Motorcycle license
-- 'drive_truck'- Truck license

-- Example queries to check licenses:

-- Check all licenses for a player
-- SELECT * FROM user_licenses WHERE owner = 'license:YOUR_LICENSE_HERE';

-- Check if player has DMV license
-- SELECT * FROM user_licenses WHERE owner = 'license:YOUR_LICENSE_HERE' AND type = 'dmv';

-- Manually add a license (for testing)
-- INSERT INTO user_licenses (type, owner) VALUES ('dmv', 'license:YOUR_LICENSE_HERE');

-- Remove a license
-- DELETE FROM user_licenses WHERE owner = 'license:YOUR_LICENSE_HERE' AND type = 'dmv';

-- Remove all licenses for a player
-- DELETE FROM user_licenses WHERE owner = 'license:YOUR_LICENSE_HERE';

-- =============================================
-- MIGRATION FROM OLD DMV SCRIPT
-- =============================================

-- If you're migrating from the old  nexus_dmv,
-- the licenses should work automatically as they use
-- the same esx_license system and license types.

-- Just ensure esx_license resource is running:
-- ensure esx_license
-- ensure nexus_dmv

-- =============================================
-- NOTES
-- =============================================

-- 1. This resource requires esx_license to be installed and running
-- 2. Licenses are stored with the 'license:' identifier as the owner
-- 3. Players must have DMV license before taking driving tests
-- 4. All license types are configurable in config.lua
-- 5. Use admin commands to manually manage licenses if needed:
--    /checklicense [player id]
--    /givelicense [player id] [license type]

-- =============================================
