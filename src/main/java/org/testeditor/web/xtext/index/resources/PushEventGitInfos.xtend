package org.testeditor.web.xtext.index.resources

import org.eclipse.xtext.util.Pair
import org.eclipse.xtext.util.Tuples
import com.fasterxml.jackson.databind.JsonNode

class PushEventGitInfos {
	
	def boolean isPushEvent(RepoEvent repoEvent) {
		val changesCount = repoEvent.nativeEventPayload.get("push")?.get("changes")?:emptyList
		return changesCount.size > 0
	}
	
	def Pair<String,String> getOldNewHeadCommitIds(RepoEvent repoEvent) {
		val change = repoEvent.nativeEventPayload.get("push")?.get("changes")?.get(0)	
		val oldCommit = change.getAsString("old", "target", "hash")
		val newCommit = change.getAsString("new", "target", "hash")
		return Tuples.create(oldCommit, newCommit)
	}
	
	private def String getAsString(JsonNode rootNode, String ... segments){
		segments.fold(rootNode) [node,segment|
			node?.get(segment)
		]?.asText
	}
	
}