import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/issue_model.dart';
import '../data/repositories/issues_repository.dart';

final myIssuesProvider = FutureProvider<List<IssueModel>>((ref) {
  return ref.read(issuesRepositoryProvider).getMyIssues();
});

final openIssuesProvider = FutureProvider<List<IssueModel>>((ref) {
  return ref.read(issuesRepositoryProvider).getOpenIssues();
});

final issueDetailProvider = FutureProvider.family<IssueModel, int>((ref, id) {
  return ref.read(issuesRepositoryProvider).getIssue(id);
});
