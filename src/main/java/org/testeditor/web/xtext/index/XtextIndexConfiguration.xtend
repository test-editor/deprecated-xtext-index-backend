package org.testeditor.web.xtext.index

import com.fasterxml.jackson.annotation.JsonProperty
import io.dropwizard.Configuration
import org.hibernate.validator.constraints.NotEmpty

public class XtextIndexConfiguration extends Configuration {

	@NotEmpty var String repoLocation
	@NotEmpty var String repoUrl

	@JsonProperty
	def getRepoLocation() {
		return repoLocation
	}

	@JsonProperty
	def setRepoLocation(String repoLocation) {
		this.repoLocation = repoLocation
	}

	@JsonProperty
	def getRepoUrl() {
		return repoUrl
	}

	@JsonProperty
	def setRepoUrl(String repoUrl) {
		this.repoUrl = repoUrl
	}

}
