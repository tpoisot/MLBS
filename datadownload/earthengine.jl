using EarthEngine

# This file cannot be run in non-interactive mode if you have not already
# downloaded an authentication token
Initialize()

# Function to cloud mask from the pixel_qa band of Landsat 8 SR data.
function maskL8sr(image)
    image = EE.Image(image) # cast to make sure we have the correct type

    # Bits 3 and 4 are cloud and cloud shadow, respectively.
    cloudShadowBitMask = 1 << 3
    cloudsBitMask = 1 << 4

    # Get the pixel QA band.
    qa = select(image, "QA_PIXEL")

    # Both flags should be set to zero, indicating clear conditions.
    mask = And(
        eq(bitwiseAnd(qa, cloudShadowBitMask), 0),
        eq(bitwiseAnd(qa, cloudsBitMask), 0),
    )

    # Return the masked image, scaled to reflectance, without the QA bands.
    return copyProperties(
        select(
            divide(
                updateMask(
                    image,
                    mask,
                ),
                2.75e5,
            ),
            "SR_B[0-9]*",
        ),
        image, ["system:time_start"],
    )
end

# get the landsat collection and filter by date
collection = filterDate(
    EE.ImageCollection("LANDSAT/LC08/C02/T1_L2"),
    "2017-03-01", "2017-10-31",
)

# Data spec: https://developers.google.com/earth-engine/datasets/catalog/LANDSAT_LC08_C02_T1_L2#bands

# apply the quality masking function
masked = map(collection, maskL8sr)

# calculate median pixel
composite = median(masked)

# define a region to view results
corsica = Point(9.141445, 41.455772)
#corsica = Point(-73.870354, 45.485857)
region = bounds(buffer(corsica, 1.1e4))

# Get a link to view results in false color composite
getThumbURL(
    composite,
    Base.Dict(
        :bands => "SR_B6,SR_B5,SR_B2",
        :min => 0.05,
        :max => 0.15,
        :gamma => 1.9,
        :region => region,
        :dimensions => 1024,
    ),
)

# This will return a zip file with the geotiff layers, at a 25m resolution
getDownloadURL(
    composite,
    Base.Dict(
        :filePerBand => true,
        :name => "LandSat",
        :bands => ["SR_B2", "SR_B3", "SR_B4", "SR_B5", "SR_B6", "SR_B7"],
        :region => region,
        :scale => 25,
    ),
)