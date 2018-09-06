# name: secondary-smtp-settings
# about: Alternative smtp settings over global smtp
# version: 0.0.1
# authors: Mudasir Raza

enabled_site_setting :smtp_enabled

after_initialize do

  ::Admin::EmailController.class_eval do
    alias_method :custom_action_mailer_settings, :action_mailer_settings

    def action_mailer_settings
      if SiteSetting.smtp_enabled
        SecondarySmtpSettings.get_secondary_smtp_settings
      else
        custom_action_mailer_settings
      end
    end
  end

  module SecondarySmtpSettings
    extend ActiveSupport::Concern

    included do
      after_action :secondary_delivery, if: proc { SiteSetting.smtp_enabled }
    end

    def secondary_delivery
      mail.delivery_method.settings = SecondarySmtpSettings.get_secondary_smtp_settings
    end

    def self.get_secondary_smtp_settings
      settings = {
        address:              SiteSetting.smtp_address,
        port:                 SiteSetting.smtp_port,
        domain:               SiteSetting.smtp_domain,
        user_name:            SiteSetting.smtp_user_name,
        password:             SiteSetting.smtp_password,
        authentication:       SiteSetting.smtp_authentication,
        enable_starttls_auto: SiteSetting.smtp_enable_start_tls
      }

      settings[:openssl_verify_mode] = SiteSetting.smtp_openssl_verify_mode if SiteSetting.smtp_openssl_verify_mode
      settings.reject { |_, y| y.blank? }
    end
  end

  ::AdminConfirmationMailer.class_eval do
    include SecondarySmtpSettings
  end

  ::DownloadBackupMailer.class_eval do
    include SecondarySmtpSettings
  end

  ::InviteMailer.class_eval do
    include SecondarySmtpSettings
  end

  ::RejectionMailer.class_eval do
    include SecondarySmtpSettings
  end

  ::SubscriptionMailer.class_eval do
    include SecondarySmtpSettings
  end

  ::TestMailer.class_eval do
    include SecondarySmtpSettings
  end

  ::UserNotifications.class_eval do
    include SecondarySmtpSettings
  end

  ::VersionMailer.class_eval do
    include SecondarySmtpSettings
  end

end