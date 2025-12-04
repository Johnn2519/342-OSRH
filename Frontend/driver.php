<?php
// ...existing code...
?><!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title>Driver</title>
	<style>
		:root {
			font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
			background: #f5f5f7;
			color: #1c1c1c;
		}

		body {
			margin: 0;
			background: #f5f5f7;
			padding: 0;
		}

		header {
			background: #fff;
			border-bottom: 1px solid #dee2e6;
			padding: 1rem;
			width: 100%;
		}

		nav ul {
			list-style: none;
			margin: 0;
			padding: 0;
			display: flex;
			gap: 1rem;
			justify-content: center;
		}

		nav li {
			display: inline;
		}

		nav a {
			text-decoration: none;
			color: #4a67f5;
			padding: 0.85rem;
			border: none;
			border-radius: 8px;
			background: #fff;
			font-weight: 600;
			cursor: pointer;
			transition: background 0.2s;
		}

		nav a:hover {
			background: #e9ecef;
		}

		/* Account card styles (copied from user) */
		.card {
			background: #fff;
			border-radius: 12px;
			padding: 2rem;
			box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
			width: min(400px, 100%);
			margin: 1.5rem auto;
		}

		form.account-form {
			display: flex;
			flex-direction: column;
			gap: 1rem;
		}

		label.account-label {
			font-weight: 600;
			font-size: 0.95rem;
		}

		input.account-input,
		select.account-input {
			padding: 0.75rem;
			border-radius: 8px;
			border: 1px solid #d0d0d0;
			font-size: 1rem;
		}

		button.account-btn {
			padding: 0.85rem;
			border: none;
			border-radius: 8px;
			background: #28a745;
			color: #fff;
			font-weight: 600;
			cursor: pointer;
		}

		/* hide/show tabs */
		.hidden {
			display: none;
		}

		.tab-active {
			background: #e9f0ff;
			color: #0a3c7d;
		}

		/* Trip card styles */
		.driver-panel {
			max-width: 720px;
			margin: 1.25rem auto;
		}

		.trip-list {
			display: flex;
			flex-direction: column;
			gap: 1rem;
		}

		.trip-card {
			background: #fff;
			border-radius: 12px;
			padding: 1rem;
			box-shadow: 0 6px 18px rgba(0, 0, 0, 0.06);
			display: flex;
			flex-direction: column;
			gap: 0.5rem;
			border: 1px solid #eee;
		}

		.trip-row {
			display: flex;
			justify-content: space-between;
			gap: 0.5rem;
			align-items: center;
		}

		.trip-point {
			font-size: 0.95rem;
			color: #1c1c1c;
		}

		.trip-actions {
			display: flex;
			gap: 0.5rem;
		}

		/* Buttons styled to match index: primary blue and green */
		.btn {
			padding: 0.6rem 0.9rem;
			border-radius: 8px;
			border: none;
			cursor: pointer;
			font-weight: 600;
			color: #fff;
		}

		.btn-primary {
			background: #4a67f5;
		}

		.btn-success {
			background: #28a745;
		}

		.btn-danger {
			background: #cc1f1a;
		}

		.trip-status {
			padding: 0.5rem 0.75rem;
			border-radius: 8px;
			font-size: 0.9rem;
			width: max-content;
			color: #fff;
		}

		.trip-status.accepted {
			background: #0f7b2d;
		}

		.trip-status.rejected {
			background: #8b1f1a;
		}
	</style>
</head>

<body>
	<header>
		<nav>
			<ul>
				<li><a href="#request-ride" class="tab-link" data-target="request-ride">Driver panel</a></li>
				<li><a href="#account" class="tab-link" data-target="account">Account</a></li>
				<li><a href="index.php">Log out</a></li>
			</ul>
		</nav>
	</header>

	<!-- Driver panel: list of trip cards (only visible when the Driver panel tab is active) -->
	<section id="request-ride" class="card hidden" aria-labelledby="request-ride-heading">
		<div class="driver-panel">
			<h2 id="request-ride-heading">Driver panel</h2>
			<div class="trip-list" id="tripList">
				<!-- Example trip card (server should render real pending trips here) -->
				<article class="trip-card" data-trip-id="trip_001">
					<div class="trip-row">
						<div>
							<div class="trip-point"><strong>From:</strong> Eleftheria Square, Nicosia</div>
							<div class="trip-point"><strong>To:</strong> Ledra Street, Nicosia</div>
						</div>
						<div class="trip-actions">
							<button class="btn btn-success btn-accept">Accept</button>
							<button class="btn btn-danger btn-reject">Reject</button>
						</div>
					</div>
					<div class="trip-row">
						<small style="color:#666;">Requested: 2025-01-02 09:12</small>
						<div class="trip-status" aria-hidden="true" style="display:none;"></div>
					</div>
				</article>

				<!-- Duplicate/example card -->
				<article class="trip-card" data-trip-id="trip_002">
					<div class="trip-row">
						<div>
							<div class="trip-point"><strong>From:</strong> Nicosia General Hospital</div>
							<div class="trip-point"><strong>To:</strong> University of Cyprus</div>
						</div>
						<div class="trip-actions">
							<button class="btn btn-success btn-accept">Accept</button>
							<button class="btn btn-danger btn-reject">Reject</button>
						</div>
					</div>
					<div class="trip-row">
						<small style="color:#666;">Requested: 2025-01-02 09:20</small>
						<div class="trip-status" aria-hidden="true" style="display:none;"></div>
					</div>
				</article>
			</div>
		</div>
	</section>

	<!-- Account card copied from user.php (hidden by default; shown via tabs) -->
	<section id="account" class="card hidden" aria-labelledby="account-heading">
		<h2 id="account-heading">Account</h2>
		<form class="account-form" method="post" action="">
			<div>
				<label class="account-label" for="username">Username</label>
				<input class="account-input" type="text" id="username" name="username" value="demo@site.com" required>
			</div>
			<div>
				<label class="account-label" for="first_name">First Name</label>
				<input class="account-input" type="text" id="first_name" name="first_name" value="John" required>
			</div>
			<div>
				<label class="account-label" for="last_name">Last Name</label>
				<input class="account-input" type="text" id="last_name" name="last_name" value="Doe" required>
			</div>
			<div>
				<label class="account-label" for="dob">Date of Birth</label>
				<input class="account-input" type="date" id="dob" name="dob" value="1990-01-01" required>
			</div>
			<div>
				<label class="account-label" for="gender">Gender</label>
				<select class="account-input" id="gender" name="gender" required>
					<option value="">Select Gender</option>
					<option value="male">Male</option>
					<option value="female">Female</option>
					<option value="non-binary">Non-binary</option>
					<option value="other">Other</option>
				</select>
			</div>
			<div>
				<label class="account-label" for="address">Address</label>
				<input class="account-input" type="text" id="address" name="address" value="123 Main St" required>
			</div>
			<div>
				<label class="account-label" for="phone">Phone</label>
				<input class="account-input" type="text" id="phone" name="phone" value="123-456-7890" required>
			</div>
			<div>
				<label class="account-label" for="email">Email</label>
				<input class="account-input" type="email" id="email" name="email" value="demo@site.com" required>
			</div>
			<fieldset>
				<legend>Documents</legend>
				<div>
					<label for="document_file">Drivers License Certificate</label>
					<input type="file" id="document_file" name="document_file" accept=".pdf,.jpg,.png">
				</div>
				<div>
					<label for="date_issued">Date Issued</label>
					<input type="date" id="date_issued" name="date_issued" required>
				</div>
				<div>
					<label for="expiry_date">Expiry Date</label>
					<input type="date" id="expiry_date" name="expiry_date" required>
				</div>
				<div style="margin: 1rem 0;"></div>
				<div>
					<label for="criminal_record_file">Criminal Record Certificate</label>
					<input type="file" id="criminal_record_file" name="criminal_record_file" accept=".pdf,.jpg,.png">
				</div>
				<div>
					<label for="date_issued">Date Issued</label>
					<input type="date" id="date_issued" name="date_issued" required>
				</div>
				<div>
					<label for="expiry_date">Expiry Date</label>
					<input type="date" id="expiry_date" name="expiry_date" required>
				</div>
				<div style="margin: 1rem 0;"></div>
				<div>
					<label for="insurance_file">Insurance Coverage Certificate</label>
					<input type="file" id="insurance_file" name="insurance_file" accept=".pdf,.jpg,.png">
				</div>
				<div>
					<label for="date_issued">Date Issued</label>
					<input type="date" id="date_issued" name="date_issued" required>
				</div>
				<div>
					<label for="expiry_date">Expiry Date</label>
					<input type="date" id="expiry_date" name="expiry_date" required>
				</div>
			</fieldset>
			<button class="account-btn" type="submit">Update Account</button>
		</form>
	</section>

	<script>
		// simple tab behavior (matches user.php)
		(function () {
			const links = document.querySelectorAll('.tab-link');
			const sections = document.querySelectorAll('section.card');
			function show(id) {
				sections.forEach(s => s.classList.toggle('hidden', s.id !== id));
				links.forEach(l => l.classList.toggle('tab-active', l.dataset.target === id));
			}
			links.forEach(l => {
				l.addEventListener('click', (e) => {
					e.preventDefault();
					const target = l.dataset.target;
					if (target) {
						history.replaceState(null, '', '#' + target);
						show(target);
					}
				});
			});
			const start = location.hash ? location.hash.replace('#', '') : 'request-ride';
			show(start);
		})();

		// Accept / Reject handlers for trip cards
		(function () {
			function setStatus(card, status) {
				const statusEl = card.querySelector('.trip-status');
				statusEl.style.display = 'inline-block';
				if (status === 'accepted') {
					statusEl.textContent = 'Accepted';
					statusEl.classList.remove('rejected');
					statusEl.classList.add('accepted');
				} else if (status === 'rejected') {
					statusEl.textContent = 'Rejected';
					statusEl.classList.remove('accepted');
					statusEl.classList.add('rejected');
				}
				// hide action buttons after decision
				card.querySelectorAll('.btn-accept, .btn-reject').forEach(b => b.style.display = 'none');
			}

			document.getElementById('tripList').addEventListener('click', function (e) {
				const btn = e.target.closest('button');
				if (!btn) return;
				const card = btn.closest('.trip-card');
				if (!card) return;
				if (btn.classList.contains('btn-accept')) {
					// update UI
					setStatus(card, 'accepted');
					// TODO: send accept to server (AJAX) using trip id:
					// fetch('/driver/respond', { method:'POST', body: new URLSearchParams({ action:'driver_respond_request', notif_request_id: card.dataset.tripId, notif_decision: 'accept' })})
				} else if (btn.classList.contains('btn-reject')) {
					setStatus(card, 'rejected');
					// TODO: send reject to server
				}
			});
		})();
	</script>

	<!-- ...existing code... -->
</body>

</html>