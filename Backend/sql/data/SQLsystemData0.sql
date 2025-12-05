--USER
SET IDENTITY_INSERT [dbo].[USER] ON;
INSERT INTO [USER] ([userID], [username], [name], [surname], [dob], [gender], [email], [address], [phone], [userType], [rating], [password])
VALUES (0, 'company', 'Company', 'Account', '2000-01-01', 4, 'company@gmail.com', NULL, '+35722000000', 5, NULL, 'Company1Password')
SET IDENTITY_INSERT [dbo].[USER] OFF;

--USERTYPE
--1
INSERT INTO [USERTYPE] ([name])
VALUES ('System Manager')
--2
INSERT INTO [USERTYPE] ([name])
VALUES ('System Worker')
--3
INSERT INTO [USERTYPE] ([name])
VALUES ('Participating Driver')
--4
INSERT INTO [USERTYPE] ([name])
VALUES ('Simple User')
--5
INSERT INTO [USERTYPE] ([name])
VALUES ('Company')


--DOCSTATUS
--1
INSERT INTO [DOCSTATUS] ([name], [okToRun])
VALUES ('Submitted', '0')
--2
INSERT INTO [DOCSTATUS] ([name], [okToRun])
VALUES ('Pending', '0')
--3
INSERT INTO [DOCSTATUS] ([name], [okToRun])
VALUES ('Rejected', '0')
--4
INSERT INTO [DOCSTATUS] ([name], [okToRun])
VALUES ('Approved', '1')


--GENDER
--1
INSERT INTO [GENDER] ([name])
VALUES ('Female')
--2
INSERT INTO [GENDER] ([name])
VALUES ('Male')
--3
INSERT INTO [GENDER] ([name])
VALUES ('Non-binary')
--4
INSERT INTO [GENDER] ([name])
VALUES ('Not specified')


--TripStatus
--1
INSERT INTO [TRIPSTATUS] ([name])
VALUES ('Requested')
--2
INSERT INTO [TRIPSTATUS] ([name])
VALUES ('Loading')
--3
INSERT INTO [TRIPSTATUS] ([name])
VALUES ('In progress')
--4
INSERT INTO [TRIPSTATUS] ([name])
VALUES ('Completed')


--PayType
--1
INSERT INTO [PAYTYPE] ([name])
VALUES ('Ride')
--2
INSERT INTO [PAYTYPE] ([name])
VALUES ('Drivers commission')
--3
INSERT INTO [PAYTYPE] ([name])
VALUES ('Refund')
--4
INSERT INTO [PAYTYPE] ([name])
VALUES ('Drivers penalty')


--PaymentMethod
--1
INSERT INTO [PAYMENTMETHOD] ([name])
VALUES ('Debit Card')
--2
INSERT INTO [PAYMENTMETHOD] ([name])
VALUES ('Credit Card')
--3
INSERT INTO [PAYMENTMETHOD] ([name])
VALUES ('Cash')
--4
INSERT INTO [PAYMENTMETHOD] ([name])
VALUES ('JCC')
--5
INSERT INTO [PAYMENTMETHOD] ([name])
VALUES ('PayPal')
--6
INSERT INTO [PAYMENTMETHOD] ([name])
VALUES ('Bank Transfer')


--TripLogAction
--1
INSERT INTO [TRIPLOGACTION] ([name])
VALUES ('Sent')
--2
INSERT INTO [TRIPLOGACTION] ([name])
VALUES ('Seen')
--3
INSERT INTO [TRIPLOGACTION] ([name])
VALUES ('Accepted')
--4
INSERT INTO [TRIPLOGACTION] ([name])
VALUES ('Denied')
--5
INSERT INTO [TRIPLOGACTION] ([name])
VALUES ('Cancelled')


--DocTypeType
--1
INSERT INTO [DOCTYPETYPE] ([name])
VALUES ('For a vehicle')
--2
INSERT INTO [DOCTYPETYPE] ([name])
VALUES ('For a driver')

--DocType
--1
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('MOT', 1)
--2
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('ADEIA KIKLOFORIAS', 1)
--3
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('TAKSINOMISI CERT', 1)
--4
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('PIC', 1)
--5
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('DOCTORS NOTE', 2)
--6
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('id', 2)
--7
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('psych NOTE', 2)
--8
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('driving lic', 2)
--9
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('adeia paramonis0', 2)
--10
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('monimi katoikia', 2)
--11
INSERT INTO [DOCTYPE] ([name], [type])
VALUES ('passport', 2)