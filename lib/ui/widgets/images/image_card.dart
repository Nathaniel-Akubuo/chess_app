import 'package:cached_network_image/cached_network_image.dart';
import 'package:chess_app/ui/common/app_colors.dart';
import 'package:chess_app/ui/common/ui_helpers.dart';
import 'package:chess_app/ui/widgets/general/custom_sizedbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../buttons/custom_card.dart';

class ImageCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final String imageURL;
  final BorderRadius? borderRadius;
  final Color? color;
  final GestureTapCallback? onTap;
  final bool _isLocal;
  final BoxFit? fit;

  final double? placeholderSize;
  final bool responsive;

  const ImageCard.network(
    this.imageURL, {
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.size,
    this.color,
    this.onTap,
    this.fit,
    this.responsive = false,
    this.placeholderSize,
  }) : _isLocal = false;

  const ImageCard.local(
    this.imageURL, {
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.size,
    this.color,
    this.onTap,
    this.fit,
    this.responsive = false,
    this.placeholderSize,
  }) : _isLocal = true;

  String get _path => imageURL.startsWith('assets/') ? imageURL : 'assets/$imageURL';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        children: [
          imageURL.isEmpty
              ? CustomCard(
                  width: size ?? width,
                  height: size ?? height,
                  child: _shimmer(size ?? width ?? 0, size ?? height ?? 0),
                )
              : _isLocal
                  ? imageURL.contains('svg')
                      ? _Svg(
                          _path,
                          width: width,
                          height: height,
                          size: size,
                          color: color,
                          fit: fit,
                        )
                      : Image.asset(
                          _path,
                          fit: fit ?? BoxFit.contain,
                          width: (size ?? width),
                          height: (size ?? height),
                          color: color,
                        )
                  : CachedNetworkImage(
                      imageUrl: imageURL,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      color: color,
                      fit: fit ?? BoxFit.cover,
                      width: (size ?? width),
                      height: (size ?? height),
                      errorWidget: (context, url, error) => _shimmer(
                        (placeholderSize ?? size ?? width ?? 0),
                        (placeholderSize ?? size ?? height ?? 0),
                      ),
                      placeholder: (context, url) => _shimmer(
                        (placeholderSize ?? size ?? width ?? 0),
                        (placeholderSize ?? size ?? height ?? 0),
                      ),
                    ),
          if (onTap != null)
            CustomSizedbox(
              height: height,
              width: width,
              size: size,
              child: Material(
                color: color ?? Colors.white,
                type: MaterialType.transparency,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.zero,
                ),
                child: InkWell(
                  onTap: onTap ?? () {},
                  customBorder: RoundedRectangleBorder(
                    borderRadius: borderRadius ?? BorderRadius.zero,
                  ),
                  child: const SizedBox.shrink(),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _shimmer(double width, double height) {
    return Shimmer.fromColors(
      baseColor: kShimmerBaseColor,
      highlightColor: kShimmerHighlightColor,
      child: CustomCard(
        width: width,
        height: height,
        border: k1pxBorder,
        borderRadius: borderRadius,
      ),
    );
  }
}

class _Svg extends StatelessWidget {
  final String path;
  final num? size;
  final num? height;
  final num? width;
  final Color? color;
  final BoxFit? fit;

  const _Svg(
    this.path, {
    this.size,
    this.color,
    this.height,
    this.width,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: (size ?? height)?.toDouble(),
      width: (size ?? width)?.toDouble(),
      fit: fit ?? BoxFit.contain,
      colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
