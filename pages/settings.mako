<%namespace module="copyvios.settings" import="main"/>\
<% bot, status, langs, projects = main(environ, headers, cookies) %>\
<%include file="/support/header.mako" args="environ=environ, cookies=cookies, title='Settings - Earwig\'s Copyvio Detector'"/>\
<%! from json import dumps, loads %>\
            % if status:
                <div id="info-box" class="green-box">
                    <p>${status}</p>
                </div>
            % endif
            <p>This page contains some configurable options for the copyvio detector. Settings are saved as cookies. You can view and delete all cookies generated by this site at the bottom of this page.</p>
            <form action="${environ['REQUEST_URI']}" method="post">
                <table>
                    <tr>
                        <td>Default site:</td>
                        <td>
                            <span class="mono">http://</span>
                            <select name="lang">
                                <% selected_lang = cookies["CopyviosDefaultLang"].value if "CopyviosDefaultLang" in cookies else bot.wiki.get_site().lang %>\
                                % for code, name in langs:
                                    % if code == selected_lang:
                                        <option value="${code | h}" selected="selected">${name}</option>
                                    % else:
                                        <option value="${code | h}">${name}</option>
                                    % endif
                                % endfor
                            </select>
                            <span class="mono">.</span>
                            <select name="project">
                                <% selected_project = cookies["CopyviosDefaultProject"].value if "CopyviosDefaultProject" in cookies else bot.wiki.get_site().project %>\
                                % for code, name in projects:
                                    % if code == selected_project:
                                        <option value="${code | h}" selected="selected">${name}</option>
                                    % else:
                                        <option value="${code | h}">${name}</option>
                                    % endif
                                % endfor
                            </select>
                            <span class="mono">.org</span>
                        </td>
                    </tr>
                    <%
                        background_options = [
                            ("list", 'Randomly select from <a href="http://commons.wikimedia.org/wiki/User:The_Earwig/POTD">a subset</a> of previous <a href="//commons.wikimedia.org/">Wikimedia Commons</a> <a href="//commons.wikimedia.org/wiki/Commons:Picture_of_the_day">Pictures of the Day</a> that work well as widescreen backgrounds, refreshed daily (default).'),
                            ("potd", 'Use the current Commons Picture of the Day, unfiltered. Certain POTDs may be unsuitable as backgrounds due to their aspect ratio or subject matter.'),
                            ("plain", "Use a plain background."),
                        ]
                        selected = cookies["CopyviosBackground"].value if "CopyviosBackground" in cookies else "list"
                    %>\
                    % for i, (value, desc) in enumerate(background_options):
                        <tr>
                            % if i == 0:
                                <td>Background:</td>
                            % else:
                                <td>&nbsp;</td>
                            % endif
                            <td>
                                <input type="radio" name="background" value="${value}" ${'checked="checked"' if value == selected else ''} /> ${desc}
                            </td>
                        </tr>
                    % endfor
                    <tr>
                        <td colspan="2">
                            <input type="hidden" name="action" value="set"/>
                            <button type="submit">Save</button>
                        </td>
                    </tr>
                </table>
            </form>
            <h2>Cookies</h2>
            % if cookies:
                <table>
                <% cookie_order = ["CopyviosDefaultProject", "CopyviosDefaultLang", "CopyviosBackground", "CopyviosShowDetails", "CopyviosScreenCache"] %>\
                % for key in [key for key in cookie_order if key in cookies]:
                    <% cookie = cookies[key] %>\
                    <tr>
                        <td><b><span class="mono">${key | h}</span></b></td>
                        % try:
                            <% lines = dumps(loads(cookie.value), indent=4).splitlines() %>\
                            <td>
                                % for line in lines:
                                    <span class="mono"><div class="indentable">${line | h}</div></span>
                                % endfor
                            </td>
                        % except ValueError:
                            <td><span class="mono">${cookie.value | h}</span></td>
                        % endtry
                        <td>
                            <form action="${environ['REQUEST_URI']}" method="post">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="cookie" value="${key | h}">
                                <button type="submit">Delete</button>
                            </form>
                        </td>
                    </tr>
                % endfor
                    <tr>
                        <td>
                            <form action="${environ['REQUEST_URI']}" method="post">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="all" value="1">
                                <button type="submit">Delete all</button>
                            </form>
                        </td>
                    </tr>
                </table>
            % else:
                <p>No cookies!</p>
            % endif
<%include file="/support/footer.mako" args="environ=environ, cookies=cookies"/>
