DELIMITER $$

CREATE TRIGGER check_one_value BEFORE insert ON follows
FOR EACH ROW
begin
    IF NEW.follower_id = new.follows_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Update Canceled. Birthday must be in the past!';
    END IF;
END$$

DELIMITER ;
