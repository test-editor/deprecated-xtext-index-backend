package org.testeditor.web.xtext.index

import com.fasterxml.jackson.annotation.JsonProperty
import io.dropwizard.Configuration
import org.hibernate.validator.constraints.NotEmpty

public class XtextIndexHelloWorldConfiguration extends Configuration {
	@NotEmpty var String template
	@NotEmpty var String defaultName = "Stranger"

	@NotEmpty var String repoLocation

	@JsonProperty
	def getRepoLocation() {
		return repoLocation
	}

	@JsonProperty
	def setRepoLocation(String repoLocation) {
		this.repoLocation = repoLocation
	}

	@JsonProperty
	def getTemplate() {
		template
	}

	@JsonProperty
	def setTemplate(String template) {
		this.template = template
	}

	@JsonProperty
	def getDefaultName() {
		defaultName
	}

	@JsonProperty
	def setDefaultName(String defaultName) {
		this.defaultName = defaultName
	}

}
