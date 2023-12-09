using EarthEngine

# This file cannot be run in non-interactive mode if you have not already
# downloaded an authentication token
Initialize()

# Function to cloud mask from the pixel_qa band of Landsat 8 SR data.
function maskL8sr(image)
    image = EE.Image(image) # cast to make sure we have the correct type

    # Bits 3 and 5 are cloud shadow and cloud, respectively.
    cloudShadowBitMask = 1 << 3
    cloudsBitMask = 1 << 5

    # Get the pixel QA band.
    qa = select(image, "pixel_qa")

    # Both flags should be set to zero, indicating clear conditions.
    mask = And(
        eq(bitwiseAnd(qa, cloudShadowBitMask), 0),
        eq(bitwiseAnd(qa, cloudsBitMask), 0)
    )

    # Return the masked image, scaled to reflectance, without the QA bands.
    return copyProperties(
        select(
            divide(
                updateMask(
                    image,
                    mask
                ),
                10_000
            ),
            "B[0-9]*"
        ),
        image, ["system:time_start"]
    )
end

# get the landsat collection and filter by date
collection = filterDate(
    EE.ImageCollection("LANDSAT/LC08/C01/T1_SR"),
    "2017-01-01", "2017-12-31"
)

# apply the quality masking function
masked = map(collection, maskL8sr)

# calculate median pixel
composite = median(masked)

# define a region to view results
corsica = Point(9.141445, 41.455772)
region = bounds(buffer(corsica, 1.2e4))

# get a link to view results
getThumbURL(composite, Base.Dict(
    :bands => "B5,B6,B2",
    :min => 0.05,
    :max => 0.55,
    :gamma => 1.5,
    :region => region,
    :dimensions => 1024
))

# This will return a zip file with the geotiff layers, at a 25m resolution
getDownloadURL(composite, Base.Dict(
    :filePerBand => true,
    :name => "LandSat",
    :bands => ["B2", "B3", "B4", "B5", "B6", "B7"],
    :region => region,
    :scale => 25,
))