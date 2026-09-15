-- Reassigning a level is its own grant; admin already holds '*'.
INSERT INTO role_permissions (role_id, permission) VALUES (3, 'levels.move');
