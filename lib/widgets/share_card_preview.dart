import 'package:cash_heart/constants/gaps.dart';
import 'package:cash_heart/constants/sizes.dart';
import 'package:cash_heart/models/relationship_stats.dart';
import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_radii.dart';
import 'package:cash_heart/theme/balance_state.dart';
import 'package:cash_heart/utils/balance_copy.dart';
import 'package:cash_heart/utils/korean_particle.dart';
import 'package:cash_heart/utils/share_card_case.dart';
import 'package:cash_heart/utils/ui_helpers.dart';
import 'package:cash_heart/widgets/balance_visualization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 카드 이미지에 QR을 다시 넣는 이유(2026-07-11 실기기 검증) — 공유 시 함께 보내는
/// caption 텍스트(랜딩 링크 포함, `card_share_screen.dart` 참고)만으로는 부족했다.
/// 카카오톡으로 이미지+텍스트를 함께 보내면 수신자에게 텍스트가 아예 전달되지
/// 않고 이미지만 도착해, 링크가 통째로 사라지는 걸 실기기에서 확인했다. 이미지
/// 픽셀 안에 QR을 넣어야 어떤 메신저를 거치든(캡처·재전달까지) 링크가 함께
/// 살아남는다 — caption 텍스트는 QR을 지원하는 앱에서 원탭 편의를 위해 계속 함께 보낸다.
const _qrLandingUrl = 'https://cashheart.novelus.dev/';

/// design_handoff `ShareCard` 이식. 배경은 관계 균형 상태에 따라 자동으로
/// 정해진다. Sprint 4부터 케이스별 칭호·로고·워드마크를 포함한 실제 공유 이미지
/// 대상 — [RepaintBoundary]로 감싸 캡처되는 위젯이므로 실 기기 폭에 안전한
/// 고정폭(280)을 유지한다.
///
/// 카드는 주로 **앱을 모르는 수신자**(person_detail에서 이 카드가 대상으로 하는
/// 바로 그 지인에게 보내는 게 자연스러운 사용처)에게 전달된다. 2026-07-11 다섯
/// 차례 피드백을 거쳐 확정된 원칙:
/// - 상단 설명은 완곡한 표현("경조사 마음 카드") 대신 **직접적으로**("경조사비
///   주고받은 기록") 뭘 하는 앱/카드인지 밝히고, 카드의 첫인상이라 눈에 띄는
///   크기·굵기로 보여준다(작은 로고 아이콘은 우상단 워터마크로 대체해 제거).
/// - 우상단에 로고를 큼직하게(카드 밖으로 1/3쯤 걸치도록) 저채도로 깔아 브랜드를
///   은은하게 드러낸다 — "카드가 밋밋하다"는 지적 반영.
/// - 실제 사진이 없는 이니셜 아바타 원은 낯선 수신자에게 혼란만 주므로 쓰지 않고
///   이름을 굵은 텍스트로만 보여준다. 이름 아래엔 관계 기간 대신 **총 거래
///   횟수**만 표시한다(연차보다 거래 횟수가 더 직관적이라는 피드백).
/// - 비율(%) 숫자는 문맥 없이는 이해하기 어려워 텍스트로 보여주지 않는다 —
///   방향성은 [BalanceVisualization]의 형태 + [balanceToneMessage] 전체 문장으로만
///   전달한다(copy-tone 원칙과도 일치).
/// - 실제 금액은 [showAmount]가 true일 때 준/받은 두 줄로 나눠 보여준다(한 줄
///   압축 표기는 가독성이 떨어진다는 지적으로 폐기). 카드 공유 화면(`card_share_
///   screen.dart`)에서 기본값은 **공개**로 바뀌었다(2026-07-11 확정) — 이 위젯
///   자체의 기본 파라미터는 하위 호환을 위해 `false`로 유지.
/// - [useHonorific]으로 이름 뒤 "님"을 붙이거나 뗄 수 있다(기본 존칭). 금액 줄
///   라벨("OOO가 받은/주신 마음")도 이 이름을 그대로 써서 "드린/받은"만으로는
///   누구 기준인지 모호하다는 지적을 해소한다 — 조사(이/가)는 [pickJosa]로
///   받침 유무에 맞게 자동 선택.
class ShareCardPreview extends StatelessWidget {
  final String personName;
  final RelationshipStats stats;
  final String message;
  final ShareCardCase caseType;
  final String cardTitle;
  final bool showAmount;

  /// 지인 이름에 "님"을 붙일지(기본 true — 공유 대상이 그 지인 본인일 수 있어
  /// 존칭이 기본값). 끄면 이름을 그대로 쓴다.
  final bool useHonorific;

  const ShareCardPreview({
    super.key,
    required this.personName,
    required this.stats,
    required this.message,
    required this.caseType,
    required this.cardTitle,
    this.showAmount = false,
    this.useHonorific = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/icons/icon-white-512.png'
        : 'assets/icons/icon-black-512.png';

    final displayName = useHonorific ? '$personName님' : personName;
    final subjectJosa =
        pickJosa(displayName, withBatchim: '이', withoutBatchim: '가');

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: colors.cardGrad,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 28, offset: const Offset(0, 12)),
        ],
      ),
      // ClipRRect가 카드 모서리 밖으로 튀어나가는 워터마크 로고를 카드 둥근
      // 모서리에 맞춰 잘라낸다(그림자는 바깥 Container의 decoration이 그리므로
      // 이 clip에 영향받지 않는다).
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Stack(
          children: [
            // 우상단에 걸치는 은은한 로고 워터마크. 로고 자체는 크게(380) 두고
            // top/right를 로고 크기의 절반보다 조금 작게(-165) 밀어내 로고가
            // 정확히 1/4보다 살짝 더 드러나도록 한다(2026-07-11: "로고가 좀 더
            // 드러나게 좌하단으로 조금만 당겨줘" — 완전한 절반 offset(-190)이면
            // 딱 1/4만 보였는데, 그보다 조금 더 보이게 미세 조정).
            Positioned(
              top: -165,
              right: -165,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(logoAsset, width: 380, height: 380),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Sizes.size24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // 낯선 수신자가 한 번에 이해할 수 있도록 완곡한 표현 대신
                    // "경조사비 주고받은 기록"으로 직접 명시한다. 카드의 첫인상이라
                    // 눈에 잘 띄게 키우고 진하게(2026-07-11: 이전 크기가 너무
                    // 작고 흐렸다는 지적). "경조사비 주고받은 기록이에요"가 한
                    // 문장으로 둘째 줄에 오도록 명시적으로 줄바꿈한다(자동 줄바꿈에
                    // 맡기면 어색한 지점에서 끊길 수 있음).
                    'CashHeart 앱으로 기록한\n경조사비 주고받은 기록이에요',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.text, height: 1.4),
                  ),
                  Gaps.v16,
                  Text(
                    displayName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.text),
                  ),
                  Text(
                    stats.count > 0 ? '총 ${stats.count}번의 거래' : '함께 쌓아가는 관계예요',
                    style: TextStyle(fontSize: 12, color: colors.text2),
                  ),
                  Gaps.v16,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Sizes.size12, vertical: Sizes.size6),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadii.pillRadius,
                    ),
                    child: Text(
                      cardTitle,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.text),
                    ),
                  ),
                  Gaps.v16,
                  Text(
                    message,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text, height: 1.4),
                  ),
                  Gaps.v20,
                  if (stats.count >= 2) ...[
                    BalanceVisualization(tilt: stats.tilt),
                    Gaps.v8,
                    Text(
                      // 숫자(비율 %)는 문맥 없인 이해하기 어렵다는 지적으로 제거하고,
                      // 형태(바)+이 전체 문장만으로 방향성을 전달한다.
                      balanceToneMessage(count: stats.count, state: stats.state),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stats.state.color(colors),
                      ),
                    ),
                  ],
                  if (showAmount) ...[
                    Gaps.v16,
                    // "드린/받은 마음"은 누구 기준인지 모호하다는 지적으로,
                    // 지인 이름을 주어로 명시한 문구로 교체(2026-07-11).
                    // given(내가 줌)은 상대가 "받은" 쪽, received(내가 받음)는
                    // 상대가 "주신" 쪽이 된다.
                    _AmountRow(
                      label: '$displayName$subjectJosa 받은 마음',
                      amount: stats.given,
                      color: colors.given,
                    ),
                    Gaps.v6,
                    _AmountRow(
                      label: '$displayName$subjectJosa 주신 마음',
                      amount: stats.received,
                      color: colors.received,
                    ),
                  ],
                  Gaps.v16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: QrImageView(
                          data: _qrLandingUrl,
                          version: QrVersions.auto,
                          size: 40,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const _AmountRow({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        Gaps.h8,
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: colors.text2),
          ),
        ),
        Gaps.h8,
        Text(
          MoneyFormatter.formatAbbreviated(amount),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}
