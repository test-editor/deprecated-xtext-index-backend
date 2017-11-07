package org.testeditor.web.xtext.index

import com.fasterxml.jackson.annotation.JsonProperty
import io.dropwizard.Configuration
import org.hibernate.validator.constraints.NotEmpty

public class XtextIndexConfiguration extends Configuration {

	@NotEmpty var String repoLocation

	@JsonProperty
	def getRepoLocation() {
		return repoLocation
	}

	@JsonProperty
	def setRepoLocation(String repoLocation) {
		this.repoLocation = repoLocation
	}
}
