CREATE TABLE players (
    ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(24),
    Hash VARCHAR(60),
    Skin INT,
    Score INT,
    Kills INT,
    Deaths INT,
    x_pos FLOAT,
    y_pos FLOAT,
    z_pos FLOAT,
    angle_pos FLOAT
);
