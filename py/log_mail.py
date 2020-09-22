from datetime import datetime
import time,re
from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
import smtplib

def send_mail(from_addr, password, to_addr, smtp_server, form_msg):
	def _format_addr(send_format):
	    name, addr = parseaddr(send_format)
	    return formataddr((Header(name, 'utf-8').encode(), addr))
	msg = MIMEText(form_msg, 'plain', 'utf-8')
	msg['From'] = _format_addr('Python robot <%s>' % from_addr)
	msg['To'] = _format_addr('NGRAIN <%s>' % to_addr)
	msg['Subject'] = Header('树莓派日志', 'utf-8').encode()
	try:
		server = smtplib.SMTP_SSL(smtp_server, 465)
		#server.set_debuglevel(1)
		server.login(from_addr, password)
		server.sendmail(from_addr, [to_addr], msg.as_string())
		server.quit()
		return 'send_mail Success'
	except smtplib.SMTPException:
		return 'send_mail Faill'


def msg_log(log,type):
	msg_n=0
	msg_log=type+'.log\n\n'
	dict_date={'Jan':'01', 'Feb':'02', 'Mar':'03', 'Apr':'04', 'May':'05', 'June':'06', 'July':'07', 'Aug':'08','Sept':'09', 'Oct':'10', 'Nov':'11','Dec':'12' }
	day_date=str(datetime.now())[:10]
	log_file=open(log, 'r')
	for i in log_file.readlines():
		if type=='vsftp':
			t_log_date=re.split(r'\s+', i)
			log_date=t_log_date[4]+'-'+dict_date[t_log_date[1]]+'-'+t_log_date[2].zfill(2)
		else:
			t_log_date=i.find('[')
			log_date=i[t_log_date+8:t_log_date+12]+'-'+dict_date[i[t_log_date+4:t_log_date+7]]+'-'+i[t_log_date+1:t_log_date+3]
		if day_date==log_date:
			msg_n+=1
			msg_log=msg_log+i
	log_file.close
	return msg_log+'\ncount:'+str(msg_n)+'\n'

print(send_mail('714580117@qq.com', 'sgykzghtgewmbejc', 'ngrain@qq.com', 'smtp.qq.com', 'send:'+str(datetime.now())+'\n'+msg_log('/var/log/vsftpd.log','vsftp')+msg_log('/var/log/nginx/access.log','nginx')))





