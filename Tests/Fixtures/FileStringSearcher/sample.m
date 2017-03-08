AlertAction *confirm = [[AlertAction alloc] initWithTitle:NSLocalizedString(@"info.error.memory.full.confirm") andBlock:^{}];
[AlertController showAlertMessage:NSLocalizedString(@"info.error.memory.full.ios") confirm:confirm sender:self];
UIImage *image = [UIImage named: @"image@2x"];