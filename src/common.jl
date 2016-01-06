### common ###

import Base: call, eltype, length, size, getindex, push!

typealias SharedPtr{T} cxxt"boost::shared_ptr<$T>"

### PointType definitions ###

for name in [
    :PointXYZ,
    :PointXYZI,
    :PointXYZRGBA,
    :PointXYZRGB,
    :PointXY,
    :PointUV,
    :InterestPoint,
    :Normal,
    :Axis,
    :PointNormal,
    :PointXYZRGBNormal,
    :PointXYZRGBNormal,
    :PointXYZINormal,
    :PointXYZLNormal,
    :ReferenceFrame,
    :SHOT352,
    ]
    refname = symbol(name, :Ref)
    valorref = symbol(name, :ValOrRef)
    cppname = string("pcl::", name)
    cxxtdef = Expr(:macrocall, symbol("@cxxt_str"), cppname);
    rcppdef = Expr(:macrocall, symbol("@rcpp_str"), cppname);

    @eval begin
        global const $name = $cxxtdef
        global const $refname = $rcppdef
        global const $valorref = Union{$name, $refname}
    end

    # no args constructor
    body = Expr(:macrocall, symbol("@icxx_str"), string(cppname, "();"))
    @eval call(::Type{$name}) = $body
end

call(::Type{PointXYZ}, x, y, z) = icxx"pcl::PointXYZ($x, $y, $z);"


type PointCloud{T}
    handle::cxxt"boost::shared_ptr<pcl::PointCloud<$T>>"
end

getindex(cloud::PointCloud, i::Integer) = icxx"$(cloud.handle).get()->at($i);"

"""Create empty PointCloud instance"""
function call{T}(::Type{PointCloud{T}})
    handle = icxx"boost::shared_ptr<pcl::PointCloud<$T>>(new pcl::PointCloud<$T>);"
    PointCloud(handle)
end

"""Create PointCloud instance and then load PCD data."""
function call{T}(::Type{PointCloud{T}}, pcd_file::AbstractString)
    handle = icxx"boost::shared_ptr<pcl::PointCloud<$T>>(new pcl::PointCloud<$T>);"
    cloud = PointCloud(handle)
    pcl.loadPCDFile(pcd_file, cloud)
    return cloud
end

length(cloud::PointCloud) = convert(Int, icxx"$(cloud.handle)->size();")
width(cloud::PointCloud) = convert(Int, icxx"$(cloud.handle)->width;")
height(cloud::PointCloud) = convert(Int, icxx"$(cloud.handle)->height;")
is_dense(cloud::PointCloud) = icxx"$(cloud.handle)->is_dense;"
points(cloud::PointCloud) = icxx"$(cloud.handle)->points;"

function transformPointCloud(cloud_in::PointCloud, cloud_out::PointCloud,
    transform)
    icxx"""
        pcl::transformPointCloud(*$(cloud_in.handle), *$(cloud_out.handle),
            $transform);
    """
end

type Correspondence
    handle::cxxt"pcl::Correspondence"
end

call(::Type{Correspondence}) = Correspondence(
    icxx"pcl::Correspondence();")
function call(::Type{Correspondence}, index_query, index_match, distance)
    handle = icxx"pcl::Correspondence($index_query, $index_match, $distance);"
    Correspondence(handle)
end

type Correspondences
    handle::cxxt"boost::shared_ptr<std::vector<pcl::Correspondence,
        Eigen::aligned_allocator<pcl::Correspondence>>>"
end

function call(::Type{Correspondences})
    handle = icxx"""
        boost::shared_ptr<pcl::Correspondences>(
            new pcl::Correspondences());"""
    Correspondences(handle)
end

length(cs::Correspondences) = convert(Int, icxx"$(cs.handle)->size();")
push!(cs::Correspondences, c::Correspondence) = icxx"$(cs.handle)->push_back($(c.handle));"
