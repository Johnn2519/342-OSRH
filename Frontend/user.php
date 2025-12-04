<?php
// ...existing code...
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>User</title>
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
		.card {
			background: #fff;
			border-radius: 12px;
			padding: 2rem;
			box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
			width: min(400px, 100%);
			margin: 2rem auto;
		}
		form {
			display: flex;
			flex-direction: column;
			gap: 1rem;
		}
		label {
			font-weight: 600;
			font-size: 0.95rem;
		}
		input {
			padding: 0.75rem;
			border-radius: 8px;
			border: 1px solid #d0d0d0;
			font-size: 1rem;
		}
		button {
			padding: 0.85rem;
			border: none;
			border-radius: 8px;
			background: #28a745;
			color: #fff;
			font-weight: 600;
			cursor: pointer;
		}
		/* tab/hide styles */
		.hidden { display: none; }
		.tab-active { background:#e9f0ff; color:#0a3c7d; }

		/* location button */
		.loc-btn {
			width: 32px;
			height: 32px;
			padding: 0;
			background: #fff url('images/locationicon.png') center/60% no-repeat;
			border: 1px solid #d0d0d0;
			border-radius: 8px;
			cursor: pointer;
			display: inline-block;
			vertical-align: middle;
		}
		.loc-btn:disabled { opacity: 0.6; cursor: default; }
		.loc-btn.loading { filter: brightness(0.9) saturate(0.9); }

		/* small coords text to align nicely */
		#pickup-coords { margin-left: 0.5rem; font-size:0.95rem; color:#333; }

		/* pickup row layout */
		.pickup-row {
			display: flex;
			align-items: center;
			gap: 0.5rem;
		}
		.pickup-text {
			font-weight: 600;
			font-size: 0.95rem;
			color: #1c1c1c;
		}
		/* Make the request-ride card larger than the default card used elsewhere */
		#request-ride.card {
			/* 20% smaller than previous 900px -> 720px */
			width: min(720px, 100%);
			/* slightly reduced padding */
			padding: 2rem;
		}

		/* Leaflet map container — match request-ride card width so map fills the area */
		#map {
			/* 20% smaller than previous 860px -> 688px */
			width: min(688px, 100%);
			aspect-ratio: 1 / 1;
			margin: 1rem auto 2rem;
			border-radius: 12px;
			box-shadow: 0 6px 20px rgba(0,0,0,0.06);
		}

		/* Background mirrored map (full viewport, behind UI) */
		#map-bg {
			position: fixed;
			inset: 0;
			width: 100vw;
			height: 100vh;
			z-index: 0;
			pointer-events: none;
			opacity: 0.5;               /* 50% opacity */
			transform: scaleX(-1);      /* mirror horizontally */
			filter: blur(0.5px) saturate(0.95);
		}

		/* Ensure UI sits above the background map */
		.app-content {
			position: relative;
			z-index: 1;
		}

		/* small mode buttons for placing pins */
		.mode-btn {
			padding: 0.35rem 0.5rem;
			border: 1px solid #d0d0d0;
			background: #fff;
			border-radius: 6px;
			cursor: pointer;
			font-size: 0.85rem;
			color: #1c1c1c;
		}
		.mode-btn.active {
			background: #e9f0ff;
			color: #0a3c7d;
			border-color: #a8c4ff;
		}
	</style>

	<!-- Leaflet CSS -->
	<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="" crossorigin=""/>
</head>
<body>
	<!-- Background mirrored map -->
	<div id="map-bg" aria-hidden="true"></div>

	<!-- All existing UI/content should be inside this wrapper so it appears above the bg map -->
	<div class="app-content">
	<header>
		<nav>
			<ul>
				<li><a href="#request-ride" class="tab-link" data-target="request-ride">Request a ride</a></li>
				<li><a href="#account" class="tab-link" data-target="account">Account</a></li>
				<li><a href="index.php">Log out</a></li>
			</ul>
		</nav>
	</header>

	<!-- Request ride section (hidden by default) -->
	<section id="request-ride" class="card hidden" aria-labelledby="request-ride-heading">
		<h1 id="request-ride-heading">Request service</h1>
		<form id="request-ride-form" method="post" action="">
			<!-- Service Type -->
			<div>
				<label for="ride_service_category">Service Type</label>
				<select id="ride_service_category" name="ride_service_category" required>
					<option value="">Select service type</option>
					<option value="Simple passenger ride">Simple passenger ride</option>
					<option value="Luxury passenger ride">Luxury passenger ride</option>
					<option value="Light transport">Light transport</option>
					<option value="Large transport">Large transport</option>
					<option value="Ride with stops">Ride with stops</option>
				</select>
			</div>

			<div>
				<div class="pickup-row">
					<span class="pickup-text">Pickup</span>
					<span id="pickup-coords">(not set)</span>
					<!-- mode button to enable placing pickup pin -->
					<button type="button" id="btn-place-pickup" class="mode-btn" title="Click map to drop pickup pin">Place pickup pin</button>
					<!-- removed btn-place-destination from this row -->
				</div>
				<!-- hidden inputs for coordinates -->
				<input type="hidden" id="pickup_lat" name="pickup_lat">
				<input type="hidden" id="pickup_lng" name="pickup_lng">
			</div>

			<div>
				<!-- destination coords (set via map pin) with the place-destination button next to the text -->
				<div style="margin-top:0.25rem; font-size:0.95rem; display:flex; align-items:center; gap:0.5rem;">
					<span style="font-weight:600;">Destination:</span>
					<span id="dest-coords">(not set)</span>
					<button type="button" id="btn-place-destination" class="mode-btn" title="Click map to drop destination pin">Place dest pin</button>
				</div>
 				<input type="hidden" id="ride_dest_lat" name="ride_dest_lat">
 				<input type="hidden" id="ride_dest_lng" name="ride_dest_lng">
			</div>
			<button type="submit" id="find-rides">Find rides</button>
		</form>

		<!-- Leaflet map placed inside the request-ride section so it only appears with this tab -->
		<div id="map" aria-hidden="false"></div>
	</section>

	<!-- Account section (the existing edit account card) -->
	<section id="account" class="card hidden" aria-labelledby="account-heading">
		<h1 id="account-heading">Edit Account</h1>
		<form method="post" action="">
			<div>
				<label for="username">Username</label>
				<input type="text" id="username" name="username" value="demo@site.com" required>
			</div>
			<div>
				<label for="first_name">First Name</label>
				<input type="text" id="first_name" name="first_name" value="John" required>
			</div>
			<div>
				<label for="last_name">Last Name</label>
				<input type="text" id="last_name" name="last_name" value="Doe" required>
			</div>
			<div>
				<label for="dob">Date of Birth</label>
				<input type="date" id="dob" name="dob" value="1990-01-01" required>
			</div>
			<div>
				<label for="gender">Gender</label>
				<select id="gender" name="gender" required>
					<option value="">Select Gender</option>
					<option value="male">Male</option>
					<option value="female">Female</option>
					<option value="non-binary">Non-binary</option>
					<option value="other">Other</option>
				</select>
			</div>
			<div>
				<label for="address">Address</label>
				<input type="text" id="address" name="address" value="123 Main St" required>
			</div>
			<div>
				<label for="phone">Phone</label>
				<input type="text" id="phone" name="phone" value="123-456-7890" required>
			</div>
			<div>
				<label for="email">Email</label>
				<input type="email" id="email" name="email" value="demo@site.com" required>
			</div>
			<button type="submit">Update Account</button>
		</form>
	</section>

	<script>
		// attach tab behavior: show only the selected section, support initial hash
		(function(){
			const links = document.querySelectorAll('.tab-link');
			const sections = document.querySelectorAll('section.card');
			function show(id){
				sections.forEach(s => s.classList.toggle('hidden', s.id !== id));
				links.forEach(l => l.classList.toggle('tab-active', l.dataset.target === id));
				// when request-ride tab is shown, refresh the map display
				if (id === 'request-ride' && typeof window.refreshMap === 'function') {
					window.refreshMap();
				}
			}
			links.forEach(l=>{
				l.addEventListener('click', (e)=>{
					e.preventDefault();
					const target = l.dataset.target;
					if(target) {
						history.replaceState(null, '', '#'+target);
						show(target);
					}
				});
			});
			// on load, use hash or default to request-ride
			const start = location.hash ? location.hash.replace('#','') : 'request-ride';
			// mark link active and show section
			show(start);
		})();

		// Geolocation + pin placing logic
		(function(){
			const coordsDisplay = document.getElementById('pickup-coords');
 			const destCoordsDisplay = document.getElementById('dest-coords');
 			const latInput = document.getElementById('pickup_lat');
 			const lngInput = document.getElementById('pickup_lng');
 			const destLatInput = document.getElementById('ride_dest_lat');
 			const destLngInput = document.getElementById('ride_dest_lng');
 			const form = document.getElementById('request-ride-form');
 
 			const btnPlacePickup = document.getElementById('btn-place-pickup');
 			const btnPlaceDest = document.getElementById('btn-place-destination');
 
			let currentMode = null; // 'pickup' | 'destination' | null
 
			function setMode(mode) {
				currentMode = mode;
				[btnPlacePickup, btnPlaceDest].forEach(b => b.classList.remove('active'));
				if (mode === 'pickup') btnPlacePickup.classList.add('active');
				if (mode === 'destination') btnPlaceDest.classList.add('active');
 			}
 
 			// event: user clicks "place" buttons
 			if (btnPlacePickup) btnPlacePickup.addEventListener('click', () => setMode('pickup'));
 			if (btnPlaceDest) btnPlaceDest.addEventListener('click', () => setMode('destination'));
 
 			if (form) {
 				form.addEventListener('submit', (e) => {
 					if (!latInput.value || !lngInput.value) {
 						e.preventDefault();
 						alert('Please set your pickup location by clicking the location button or dropping a pickup pin before finding rides.');
 						if (btnPlacePickup) btnPlacePickup.focus();
 						return;
 					}
 					if (!destLatInput.value || !destLngInput.value) {
 						e.preventDefault();
 						alert('Please drop a destination pin on the map before finding rides.');
 						if (btnPlaceDest) btnPlaceDest.focus();
 					}
 				});
 			}
 
 			// expose helpers to be used by map click handler
 			window.__setPickup = function(lat, lng) {
 				latInput.value = lat.toFixed(6);
 				lngInput.value = lng.toFixed(6);
 				coordsDisplay.textContent = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
 			};
 			window.__setDestination = function(lat, lng) {
 				destLatInput.value = lat.toFixed(6);
 				destLngInput.value = lng.toFixed(6);
 				destCoordsDisplay.textContent = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
 			};
 
 			// allow ESC to cancel mode
 			document.addEventListener('keydown', (ev) => {
 				if (ev.key === 'Escape') setMode(null);
 			});
 
 			// public: currentMode getter for map code
 			window.__getPinMode = function(){ return currentMode; };
 			window.__clearMode = function(){ setMode(null); };
 		})();
	</script>

	<!-- Leaflet JS -->
	<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="" crossorigin=""></script>

	<script>
		// Initialize Leaflet maps and add click handler to drop pickup/destination pins
		(function(){
			const mapEl = document.getElementById('map');
			const mapBgEl = document.getElementById('map-bg');
			let map = null;
			let pickupMarker = null;
			let destMarker = null;
			let mapBg = null;
			let pickupMarkerBg = null;
			let destMarkerBg = null;

			// Nicosia center
			const nicosia = [35.1856, 33.3823];

			function initMap() {
				if (!mapEl) return;
				if (!map) {
					map = L.map('map', { scrollWheelZoom: true }).setView(nicosia, 13);
					L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
						attribution: '&copy; OpenStreetMap contributors'
					}).addTo(map);

					// click handler to place pins depending on selected mode
					map.on('click', function(e) {
						const mode = (typeof window.__getPinMode === 'function') ? window.__getPinMode() : null;
						if (mode === 'pickup') {
							placePickup(e.latlng.lat, e.latlng.lng);
							if (typeof window.__clearMode === 'function') window.__clearMode();
						} else if (mode === 'destination') {
							placeDestination(e.latlng.lat, e.latlng.lng);
							if (typeof window.__clearMode === 'function') window.__clearMode();
						}
					});
				}
			}

			function initMapBg() {
				if (!mapBgEl) return;
				if (!mapBg) {
					mapBg = L.map('map-bg', {
						zoomControl: false,
						attributionControl: false,
						dragging: false,
						scrollWheelZoom: false,
						doubleClickZoom: false,
						boxZoom: false,
						trackResize: true,
						interactive: false
					}).setView(nicosia, 13);
					L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
						attribution: ''
					}).addTo(mapBg);
				}
			}

			function placePickup(lat, lng) {
				initMap(); initMapBg();
				const pos = [lat, lng];
				if (!pickupMarker) {
					pickupMarker = L.marker(pos, {title:'Pickup'}).addTo(map);
				} else {
					pickupMarker.setLatLng(pos);
				}
				if (!pickupMarkerBg && mapBg) {
					pickupMarkerBg = L.marker(pos).addTo(mapBg);
				} else if (pickupMarkerBg) {
					pickupMarkerBg.setLatLng(pos);
				}
				// update hidden inputs & display
				if (typeof window.__setPickup === 'function') window.__setPickup(lat, lng);
			}

			function placeDestination(lat, lng) {
				initMap(); initMapBg();
				const pos = [lat, lng];
				if (!destMarker) {
					destMarker = L.marker(pos, {title:'Destination', icon: L.icon({iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png', iconSize:[25,41], iconAnchor:[12,41]})}).addTo(map);
				} else {
					destMarker.setLatLng(pos);
				}
				if (!destMarkerBg && mapBg) {
					destMarkerBg = L.marker(pos).addTo(mapBg);
				} else if (destMarkerBg) {
					destMarkerBg.setLatLng(pos);
				}
				// update hidden inputs & display
				if (typeof window.__setDestination === 'function') window.__setDestination(lat, lng);
			}

			// expose refreshMap so the tab switcher can ensure the map renders correctly when shown
			window.refreshMap = function() {
				if (!map) initMap();
				if (!mapBg) initMapBg();
				setTimeout(() => {
					try { if (map) map.invalidateSize(); } catch (e) { /* ignore */ }
					try { if (mapBg) mapBg.invalidateSize(); } catch (e) { /* ignore */ }
				}, 150);
			};

			// initialize maps on DOM ready
			document.addEventListener('DOMContentLoaded', function(){
				initMap();
				initMapBg();
				// center both maps on Nicosia initially
				if (map) map.setView(nicosia, 13);
				if (mapBg) mapBg.setView(nicosia, 13);
			});
		})();
	</script>
	</div> <!-- .app-content -->
</body>
</html>
