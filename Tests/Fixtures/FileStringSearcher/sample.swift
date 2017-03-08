fileprivate func sample() {
    guard isLoggedIn != nil else {
        nameLabel.text  = nil
        return
    }
    
    if isTwitterLoggedIn == false {
        twitterLoginButton.setTitle(NSLocalizedString("common.login"), for: UIControlState())
        twitterScreenNameLabel.text = nil
        twitterLoginButton.setBackgroundImage(UIImage(named: "live_btn_connect"), for: UIControlState())
    }
    else {
        twitterLoginButton.setTitle(NSLocalizedString("common.logout"), for: UIControlState())
        twitterScreenNameLabel.text = twitterScreenName
        twitterLoginButton.setBackgroundImage(UIImage(named: "live_btn_connect"), for: UIControlState())
    }
    twitterLoginIndicator.isHidden = true
    twitterLoginButton.isHidden    = false
    twitterLoginButton.isEnabled   = true

    let string = NSLocalizedString("name-key", "无法支持")
}