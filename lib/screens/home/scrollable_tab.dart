/// Implemented by the home tab screens so the bottom bar can scroll the active
/// tab back to the top when its already-selected tab is tapped again.
///
/// Behaviour (per tab): switching TO a tab restores where you left off (the
/// tabs live in an IndexedStack, so scroll offset is preserved); tapping the
/// tab that is ALREADY selected calls [scrollToTop].
mixin ScrollableTab {
  void scrollToTop();
}
