CREATE OR REPLACE PROCEDURE C##VISHALBH.sendmail_oracle (fromm    VARCHAR2,
                                      too      VARCHAR2,
                                      sub      VARCHAR2,
                                      body     VARCHAR2,
                                      port     NUMBER)
IS
   objConnection   UTL_SMTP.connection;
   vrData          VARCHAR2 (32000);
BEGIN
   objConnection := UTL_SMTP.open_connection ('smtpeast.oravr.in', port);
   UTL_SMTP.helo (objConnection, 'smtpeast.oravr.in');
   UTL_SMTP.mail (objConnection, fromm);
   UTL_SMTP.rcpt (objConnection, too);
   UTL_SMTP.open_data (objConnection);
   /* ** Sending the header information */
   UTL_SMTP.write_data (objConnection, 'From: ' || fromm || UTL_TCP.CRLF);
   UTL_SMTP.write_data (objConnection, 'To: ' || too || UTL_TCP.CRLF);
   UTL_SMTP.write_data (objConnection, 'Subject: ' || sub || UTL_TCP.CRLF);
   UTL_SMTP.write_data (objConnection,
                        'MIME-Version: ' || '1.0' || UTL_TCP.CRLF);
   UTL_SMTP.write_data (objConnection, 'Content-Type: ' || 'text/html;');
   UTL_SMTP.write_data (
      objConnection,
      'Content-Transfer-Encoding: ' || '"8Bit"' || UTL_TCP.CRLF);
   UTL_SMTP.write_data (objConnection, UTL_TCP.CRLF);
   UTL_SMTP.write_data (objConnection, UTL_TCP.CRLF || '');
   UTL_SMTP.write_data (objConnection, UTL_TCP.CRLF || '');
   UTL_SMTP.write_data (
      objConnection,
         UTL_TCP.CRLF
      || '<span style="color: red; font-family: Courier New;">'
      || body
      || '</span>');
   UTL_SMTP.write_data (objConnection, UTL_TCP.CRLF || '');
   UTL_SMTP.write_data (objConnection, UTL_TCP.CRLF || '');
   UTL_SMTP.close_data (objConnection);
   UTL_SMTP.quit (objConnection);
EXCEPTION
   WHEN UTL_SMTP.transient_error OR UTL_SMTP.permanent_error
   THEN
      UTL_SMTP.quit (objConnection);
      DBMS_OUTPUT.put_line (SQLERRM);
   WHEN OTHERS
   THEN
      UTL_SMTP.quit (objConnection);
      DBMS_OUTPUT.put_line (SQLERRM);
END sendmail_oracle;
/




begin
transitha.sendmail_oracle ('dbalerts@oravr.in','info@oravr.in','Test email from 19c By vishal','Testing',25);
end;
/
