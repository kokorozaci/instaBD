CREATE DEFINER=`root`@`localhost` TRIGGER `none_to_null` BEFORE INSERT ON `users_profiles` FOR EACH ROW begin
    IF NEW.connected_fb_page = 'None' THEN
        set NEW.connected_fb_page := null;
    END IF;
   
    IF NEW.website = 'None' THEN
        set NEW.website := null;
    END IF;
   
    IF NEW.country_block = 'False' THEN
        set NEW.country_block := null;
    END IF;
END