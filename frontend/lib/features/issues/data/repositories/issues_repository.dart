import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/issue_model.dart';

final issuesRepositoryProvider = Provider<IssuesRepository>((ref) {
  return IssuesRepository(ref.read(apiClientProvider));
});

class IssuesRepository {
  final ApiClient _client;
  IssuesRepository(this._client);

  Future<List<IssueModel>> getMyIssues() async {
    final response = await _client.get('/vehicle-issues');
    final data = response.data['data'] as List;
    return data.map((e) => IssueModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<IssueModel>> getOpenIssues() async {
    final response = await _client.get('/vehicle-issues/open');
    final data = response.data['data'] as List;
    return data.map((e) => IssueModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<IssueModel> getIssue(int id) async {
    final response = await _client.get('/vehicle-issues/$id');
    return IssueModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<IssueCommentModel>> getComments(int issueId, {int afterId = 0}) async {
    final response = await _client.get(
      '/vehicle-issues/$issueId/comments',
      queryParameters: afterId > 0 ? {'after_id': afterId} : null,
    );
    final data = response.data['data'] as List;
    return data.map((e) => IssueCommentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<IssueCommentModel> postComment(int issueId, String body) async {
    final response = await _client.post(
      '/vehicle-issues/$issueId/comments',
      data: {'body': body},
    );
    return IssueCommentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
