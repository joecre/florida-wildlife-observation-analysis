# Florida Wildlife Species Predictor

import joblib
import pandas as pd
import streamlit as st
import folium
import geopandas as gpd

from shapely.geometry import Point
from streamlit_folium import st_folium

# --------------------------------------------------
# Page setup
# --------------------------------------------------

st.set_page_config(
    page_title="Florida Wildlife Species Predictor",
    layout="wide"
)

st.title("🐊 Florida Wildlife Species Predictor")

st.write(
    "Click a location in Florida to predict the most likely wildlife species."
)

# --------------------------------------------------
# Load model and county boundaries
# --------------------------------------------------

model = joblib.load("wildlife_model.pkl")
feature_columns = joblib.load("feature_columns.pkl")

counties = gpd.read_file(
    "data/florida_counties.json"
)

# --------------------------------------------------
# Initialize session state
# --------------------------------------------------

if "lat" not in st.session_state:
    st.session_state["lat"] = None

if "lon" not in st.session_state:
    st.session_state["lon"] = None

if "county" not in st.session_state:
    st.session_state["county"] = None

# --------------------------------------------------
# Create map
# --------------------------------------------------

m = folium.Map(
    location=[27.8, -81.7],
    zoom_start=6
)

# County borders
folium.GeoJson(
    counties,
    style_function=lambda x: {
        "fillOpacity": 0,
        "weight": 1
    },
    tooltip=folium.GeoJsonTooltip(
        fields=["NAME"],
        aliases=["County:"]
    )
).add_to(m)

# Marker if location already selected
if st.session_state["lat"] is not None:

    folium.Marker(
        [
            st.session_state["lat"],
            st.session_state["lon"]
        ],
        tooltip="Selected Location"
    ).add_to(m)

# --------------------------------------------------
# Display map
# --------------------------------------------------

map_data = st_folium(
    m,
    width=1000,
    height=600
)

# --------------------------------------------------
# Handle map click
# --------------------------------------------------

if map_data.get("last_clicked"):

    lat = map_data["last_clicked"]["lat"]
    lon = map_data["last_clicked"]["lng"]

    point = Point(lon, lat)

    county_match = counties[
        counties.contains(point)
    ]

    if not county_match.empty:

        county = county_match.iloc[0]["NAME"]

        st.session_state["lat"] = lat
        st.session_state["lon"] = lon
        st.session_state["county"] = county

# --------------------------------------------------
# Show selected location
# --------------------------------------------------

if st.session_state["lat"] is not None:

    st.success("Location Selected!")

    st.write(
        f"Latitude: "
        f"{st.session_state['lat']:.6f}"
    )

    st.write(
        f"Longitude: "
        f"{st.session_state['lon']:.6f}"
    )

    st.write(
        f"County: "
        f"{st.session_state['county']}"
    )

# --------------------------------------------------
# Inputs
# --------------------------------------------------

month = st.selectbox(
    "Month",
    list(range(1, 13))
)

year = st.number_input(
    "Year",
    min_value=2020,
    max_value=2035,
    value=2025
)

# --------------------------------------------------
# Prediction
# --------------------------------------------------

if st.button("Predict Species"):

    if st.session_state["lat"] is None:

        st.warning(
            "Please click a location on the map first."
        )

    else:

        input_data = pd.DataFrame(
            0,
            index=[0],
            columns=feature_columns
        )

        # Numerical features
        input_data["latitude"] = st.session_state["lat"]
        input_data["longitude"] = st.session_state["lon"]
        input_data["year"] = year
        input_data["month"] = month

        # Season
        if 5 <= month <= 10:

            input_data["season_Wet"] = 1

        else:

            input_data["season_Dry"] = 1

        # County dummy
        county_col = (
            f"place_county_name_"
            f"{st.session_state['county']}"
        )

        if county_col in input_data.columns:

            input_data[county_col] = 1

        # Prediction
        prediction = model.predict(
            input_data
        )[0]

        probabilities = model.predict_proba(
            input_data
        )[0]

        results = pd.DataFrame({
            "Species": model.classes_,
            "Probability": probabilities
        })

        results = results.sort_values(
            by="Probability",
            ascending=False
        )

        top3 = results.head(3)

        confidence = top3.iloc[0]["Probability"]

        # Main prediction
        st.success(
            f"🐾 Predicted Species: {prediction}"
        )

        # Confidence
        st.subheader("Confidence")

        st.progress(
            float(confidence)
        )

        st.write(
            f"{confidence * 100:.1f}%"
        )

        # Top 3
        st.subheader(
            "Top 3 Predictions"
        )

        st.dataframe(
            top3.assign(
                Probability=lambda x:
                (x["Probability"] * 100)
                .round(1)
                .astype(str) + "%"
            ),
            use_container_width=True
        )