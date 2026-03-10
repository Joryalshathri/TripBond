"""
Email service for sending transactional emails via SMTP.

If SMTP credentials are not configured, the verification code is printed
to the console so development still works without an email provider.
"""

import smtplib
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from ..config import get_settings

logger = logging.getLogger(__name__)


def send_verification_code_email(to_email: str, code: str, name: str = "") -> bool:
    """
    Send a 6-digit email verification code.

    Returns True on success (or when falling back to console print).
    Returns False only when SMTP is configured but the send actually fails.
    """
    config = get_settings()

    # Fallback: no SMTP configured — print so developers can still test
    if not config.smtp_host or not config.smtp_user or not config.smtp_password:
        print(f"\n{'='*50}")
        print(f"📧  VERIFICATION CODE  for {to_email}")
        print(f"    Code : {code}")
        print(f"{'='*50}\n")
        return True

    greeting = f"Hi {name}," if name else "Hi,"

    text_body = (
        f"{greeting}\n\n"
        f"Your TripBond email verification code is:\n\n"
        f"    {code}\n\n"
        f"This code expires in 10 minutes.\n\n"
        f"If you did not create a TripBond account, please ignore this email.\n\n"
        f"Best,\nThe TripBond Team"
    )

    html_body = f"""
<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0">
    <tr><td align="center" style="padding:40px 16px;">
      <table width="500" style="background:#fff;border-radius:16px;overflow:hidden;">
        <tr><td style="background:#4675B8;padding:32px;text-align:center;">
          <h1 style="margin:0;color:#fff;font-size:28px;letter-spacing:1px;">TripBond</h1>
        </td></tr>
        <tr><td style="padding:40px 40px 16px;text-align:center;">
          <p style="color:#555;font-size:15px;line-height:1.6;margin:0 0 24px;">{greeting}<br>
          Please verify your email address to start your travel journey.</p>
          <div style="background:#f0f4ff;border-radius:12px;padding:28px 24px;display:inline-block;">
            <p style="margin:0 0 10px;color:#888;font-size:12px;letter-spacing:1px;text-transform:uppercase;">
              Your verification code
            </p>
            <div style="font-size:38px;font-weight:bold;letter-spacing:14px;color:#4675B8;
                        font-family:monospace;padding:0 8px;">{code}</div>
          </div>
          <p style="color:#aaa;font-size:12px;margin:24px 0 0;line-height:1.6;">
            This code expires in <strong>10 minutes</strong>.<br>
            If you didn&rsquo;t create a TripBond account, you can safely ignore this email.
          </p>
        </td></tr>
        <tr><td style="padding:16px 40px 40px;text-align:center;">
          <p style="color:#ccc;font-size:11px;margin:0;">&copy; TripBond. All rights reserved.</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
""".strip()

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = "TripBond – Your Email Verification Code"
        msg["From"] = config.smtp_from_email or config.smtp_user
        msg["To"] = to_email
        msg.attach(MIMEText(text_body, "plain"))
        msg.attach(MIMEText(html_body, "html"))

        with smtplib.SMTP(config.smtp_host, config.smtp_port, timeout=15) as server:
            server.ehlo()
            server.starttls()
            server.login(config.smtp_user, config.smtp_password)
            server.sendmail(config.smtp_from_email or config.smtp_user, to_email, msg.as_string())

        logger.info(f"Verification email sent to {to_email}")
        return True

    except Exception as exc:
        logger.exception(f"Failed to send verification email to {to_email}: {exc}")
        # Console fallback so the app flow isn't completely broken
        print(f"\n{'='*50}")
        print(f"📧  VERIFICATION CODE  for {to_email}  (email send failed)")
        print(f"    Code : {code}")
        print(f"{'='*50}\n")
        return False
