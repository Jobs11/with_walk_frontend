import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:with_walk/api/model/faq.dart';
import 'package:with_walk/api/model/inquiry.dart';
import 'package:with_walk/api/model/inquiry_reply.dart';
import 'package:with_walk/api/model/notice.dart';
import 'package:with_walk/functions/data.dart';

class CustomerService {
  static const String manual = "customer";

  // ========================================
  // 공지사항 API
  // ========================================

  /// 전체 공지사항 조회
  static Future<List<Notice>> getAllNotices({
    int page = 1,
    int size = 20,
  }) async {
    List<Notice> notices = [];
    final url = Uri.parse('${Baseurl.b}$manual/notices').replace(
      queryParameters: {'page': page.toString(), 'size': size.toString()},
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var notice in data) {
        notices.add(Notice.fromJson(notice));
      }
      return notices;
    }
    throw Exception('공지사항 조회 실패: ${response.statusCode}');
  }

  /// 카테고리별 공지사항 조회
  static Future<List<Notice>> getNoticesByCategory(
    String category, {
    int page = 1,
    int size = 20,
  }) async {
    List<Notice> notices = [];
    final url = Uri.parse('${Baseurl.b}$manual/notices/category/$category')
        .replace(
          queryParameters: {'page': page.toString(), 'size': size.toString()},
        );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var notice in data) {
        notices.add(Notice.fromJson(notice));
      }
      return notices;
    }
    throw Exception('공지사항 조회 실패: ${response.statusCode}');
  }

  /// 공지사항 상세 조회
  static Future<Notice> getNoticeDetail(int noticeId) async {
    final url = Uri.parse('${Baseurl.b}$manual/notices/$noticeId');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Notice.fromJson(data);
    }
    throw Exception('공지사항 상세 조회 실패: ${response.statusCode}');
  }

  /// 공지사항 등록 (관리자용)
  static Future<int> createNotice(Notice notice) async {
    final url = Uri.parse('${Baseurl.b}$manual/notices');

    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(notice.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return data['notice_id'] as int;
    }
    throw Exception('공지사항 등록 실패: ${res.statusCode} ${res.body}');
  }

  /// 공지사항 수정 (관리자용)
  static Future<void> updateNotice(int noticeId, Notice notice) async {
    final url = Uri.parse('${Baseurl.b}$manual/notices/$noticeId');

    final res = await http
        .put(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(notice.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('공지사항 수정 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 공지사항 삭제 (관리자용)
  static Future<void> deleteNotice(int noticeId) async {
    final url = Uri.parse('${Baseurl.b}$manual/notices/$noticeId');

    final res = await http.delete(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('공지사항 삭제 실패: ${res.statusCode} ${res.body}');
    }
  }

  // ========================================
  // FAQ API
  // ========================================

  /// 전체 FAQ 조회
  static Future<List<Faq>> getAllFaqs() async {
    List<Faq> faqs = [];
    final url = Uri.parse('${Baseurl.b}$manual/faqs');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var faq in data) {
        faqs.add(Faq.fromJson(faq));
      }
      return faqs;
    }
    throw Exception('FAQ 조회 실패: ${response.statusCode}');
  }

  /// 카테고리별 FAQ 조회
  static Future<List<Faq>> getFaqsByCategory(String category) async {
    List<Faq> faqs = [];
    final url = Uri.parse('${Baseurl.b}$manual/faqs/category/$category');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var faq in data) {
        faqs.add(Faq.fromJson(faq));
      }
      return faqs;
    }
    throw Exception('FAQ 조회 실패: ${response.statusCode}');
  }

  /// FAQ 검색
  static Future<List<Faq>> searchFaqs(String keyword) async {
    List<Faq> faqs = [];
    final url = Uri.parse(
      '${Baseurl.b}$manual/faqs/search',
    ).replace(queryParameters: {'keyword': keyword});

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var faq in data) {
        faqs.add(Faq.fromJson(faq));
      }
      return faqs;
    }
    throw Exception('FAQ 검색 실패: ${response.statusCode}');
  }

  /// FAQ 상세 조회
  static Future<Faq> getFaqDetail(int faqId) async {
    final url = Uri.parse('${Baseurl.b}$manual/faqs/$faqId');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Faq.fromJson(data);
    }
    throw Exception('FAQ 상세 조회 실패: ${response.statusCode}');
  }

  // ========================================
  // 1:1 문의 API
  // ========================================

  /// 내 문의 목록 조회
  static Future<List<Inquiry>> getUserInquiries(String userId) async {
    List<Inquiry> inquiries = [];
    final url = Uri.parse('${Baseurl.b}$manual/inquiries/$userId');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var inquiry in data) {
        inquiries.add(Inquiry.fromJson(inquiry));
      }
      return inquiries;
    }
    throw Exception('문의 목록 조회 실패: ${response.statusCode}');
  }

  /// 전체 문의 목록 조회 (관리자용)
  static Future<List<Inquiry>> getAllInquiries() async {
    List<Inquiry> inquiries = [];
    final url = Uri.parse('${Baseurl.b}$manual/inquiries');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var inquiry in data) {
        inquiries.add(Inquiry.fromJson(inquiry));
      }
      return inquiries;
    }
    throw Exception('문의 목록 조회 실패: ${response.statusCode}');
  }

  /// 문의 상세 조회
  static Future<Inquiry> getInquiryDetail(int inquiryId) async {
    final url = Uri.parse('${Baseurl.b}$manual/inquiry/$inquiryId');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Inquiry.fromJson(data);
    }
    throw Exception('문의 상세 조회 실패: ${response.statusCode}');
  }

  /// 문의 등록
  static Future<void> createInquiry(Inquiry inquiry) async {
    final url = Uri.parse('${Baseurl.b}$manual/inquiry');

    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(inquiry.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('문의 등록 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 문의 삭제
  static Future<void> deleteInquiry(int inquiryId) async {
    final url = Uri.parse('${Baseurl.b}$manual/inquiry/$inquiryId');

    final res = await http.delete(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('문의 삭제 실패: ${res.statusCode} ${res.body}');
    }
  }

  // ========================================
  // 답변 API (관리자용)
  // ========================================

  /// 문의 답변 등록 (관리자용)
  static Future<void> replyToInquiry(InquiryReply reply) async {
    final url = Uri.parse('${Baseurl.b}$manual/reply');

    final res = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(reply.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('답변 등록 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 답변 대기 중인 문의 개수
  static Future<int> getPendingInquiryCount() async {
    final url = Uri.parse('${Baseurl.b}$manual/pending-count');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pending_count'] as int;
    }
    throw Exception('답변 대기 개수 조회 실패: ${response.statusCode}');
  }
}
