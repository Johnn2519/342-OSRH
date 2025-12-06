(() => {
  // Initialize the map when DOM is ready
  const initMap = () => {
    console.log("Initializing map...");
    const mapEl = document.getElementById("map");
    if (!mapEl) {
      console.error("Map container not found");
      return;
    }
    if (!window.L) {
      console.error("Leaflet failed to load");
      mapEl.textContent = "Map failed to load.";
      return;
    }

    let map;
    try {
      // Create map centered on Cyprus
      map = L.map(mapEl).setView([35.1667, 33.3667], 11);
      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: "&copy; OpenStreetMap contributors",
      }).addTo(map);
      console.log("Map created successfully");
    } catch (err) {
      console.error("Map initialization error:", err);
      mapEl.textContent = "Map failed to initialize.";
      return;
    }

    // Variables for active pin type and markers
    let active = "start";
    let startMarker = null;
    let endMarker = null;

    // Get form input elements for coordinates
    const startLng = document.querySelector('input[name="startLong"]');
    const startLat = document.querySelector('input[name="startLat"]');
    const endLng = document.querySelector('input[name="endtLong"]');
    const endLat = document.querySelector('input[name="endLat"]');

    // Update form fields with marker coordinates
    const updateFields = (type, latlng) => {
      const lng = latlng.lng.toFixed(6);
      const lat = latlng.lat.toFixed(6);
      if (type === "start") {
        if (startLng) startLng.value = lng;
        if (startLat) startLat.value = lat;
      } else {
        if (endLng) endLng.value = lng;
        if (endLat) endLat.value = lat;
      }
    };

    // Create and place a draggable marker
    const setMarker = (type, latlng) => {
      const label = type === "start" ? "Start" : "Destination";
      const marker = L.marker(latlng, { draggable: true })
        .bindPopup(label)
        .addTo(map);
      marker.on("dragend", () => updateFields(type, marker.getLatLng()));
      return marker;
    };

    // Handle map click to place markers
    map.on("click", (e) => {
      if (active === "start") {
        if (startMarker) map.removeLayer(startMarker);
        startMarker = setMarker("start", e.latlng);
        updateFields("start", e.latlng);
      } else {
        if (endMarker) map.removeLayer(endMarker);
        endMarker = setMarker("end", e.latlng);
        updateFields("end", e.latlng);
      }
    });

    // Handle radio button changes for pin target
    document.querySelectorAll('input[name="pinTarget"]').forEach((radio) => {
      radio.addEventListener("change", () => {
        active = radio.value === "end" ? "end" : "start";
      });
    });

    // Set active pin when focusing on start fields
    [startLng, startLat].forEach(
      (el) =>
        el &&
        el.addEventListener("focus", () => {
          active = "start";
        })
    );
    // Set active pin when focusing on end fields
    [endLng, endLat].forEach(
      (el) =>
        el &&
        el.addEventListener("focus", () => {
          active = "end";
        })
    );

    // Ensure map renders properly on load and resize
    map.whenReady(() => {
      map.invalidateSize();
      console.log("Map ready and invalidated");
    });
    window.addEventListener("load", () => {
      map.invalidateSize();
      console.log("Window load: map invalidated");
    });
    window.addEventListener("resize", () => {
      map.invalidateSize();
      console.log("Window resize: map invalidated");
    });
    setTimeout(() => {
      map.invalidateSize();
      console.log("Timeout: map invalidated");
    }, 1000);
  };

  // Initialize map when DOM is ready
  if (document.readyState === "loading") {
    window.addEventListener("DOMContentLoaded", initMap);
  } else {
    initMap();
  }
})();
