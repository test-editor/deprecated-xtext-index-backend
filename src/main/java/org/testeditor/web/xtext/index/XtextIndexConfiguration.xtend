package org.testeditor.web.xtext.index

import com.fasterxml.jackson.annotation.JsonProperty
import io.dropwizard.Configuration
import org.hibernate.validator.constraints.NotEmpty

public class XtextIndexConfiguration extends Configuration {

	@NotEmpty var String repoLocation
	@NotEmpty var String repoUrl

	/**
	 * file location used as root for the local repo
	 */
	@JsonProperty
	def getRepoLocation() {
		return repoLocation
	}

	@JsonProperty
	def setRepoLocation(String repoLocation) {
		this.repoLocation = repoLocation
	}

	/**
	 * url to git repository that is to be used for this index
	 */
	@JsonProperty
	def getRepoUrl() {
		return repoUrl
	}

	@JsonProperty
	def setRepoUrl(String repoUrl) {
		this.repoUrl = repoUrl
	}

}
